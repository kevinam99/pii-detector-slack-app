defmodule PiiDetectorWeb.WebhookController do
  use PiiDetectorWeb, :controller

  require Logger

  @slack_app_id Application.compile_env!(:pii_detector, :slack)[:app_id]
  @slack_verification_token Application.compile_env!(:pii_detector, :slack)[:verification_token]

  def slack_webhook(conn, %{"challenge" => challenge}) do
    json(conn, %{challenge: challenge})
  end

  # text message
  def slack_webhook(
        conn,
        %{
          "api_app_id" => @slack_app_id,
          "token" => @slack_verification_token,
          "event" => %{"blocks" => blocks} = event
        } = _params
      )
      when is_list(blocks) do
    with nil <- event["bot_id"],
         block when is_map(block) <- List.first(blocks),
         {:rich_text, true} <- {:rich_text, block["type"] == "rich_text"},
         text_message = event["text"],
         #  text_message =
         #    List.first(block["elements"])
         #    |> Map.get("elements")
         #    |> Enum.filter(fn map -> map["type"] == "text" end)
         #    |> List.first(%{})
         #    |> Map.get("text"),
         handle_text_message(text_message, event, :slack) do
      json(conn, %{})
    else
      _ -> json(conn, %{})
    end
  end

  def notion_webhook(conn, %{"verification_token" => token}) do
    IO.inspect(token, label: "Notion Webhook Token")
    json(conn, %{challenge: "challenge"})
  end

  def notion_webhook(conn, %{"type" => "page.created"} = params) do
    # Handle the Notion webhook event here

    with {:ok, page} <- PiiDetector.Notion.fetch_page(params["entity"]["id"]),
         {:ok, user_email} <- PiiDetector.Notion.fetch_user_email(page["created_by"]["id"]),
         {:ok, slack_user} <- PiiDetector.Slack.lookup_user_by_email(user_email),
         text = build_text_for_notion(page) do
      handle_text_message(text, %{"user" => slack_user["id"], "text" => text}, :notion)
    else
      {:error, reason} ->
        # Handle the error case
        IO.puts("Error checking PII: #{reason}")
        {:error, reason}
    end

    json(conn, %{})
  end

  def notion_webhook(conn, _params), do: json(conn, %{})

  defp handle_text_message(nil, _event, _) do
    # Handle the case where there is no text message
    nil
  end

  defp handle_text_message(text_message, event, source) when is_binary(text_message) do
    text_message = String.trim(text_message)

    with {:ok, response} <- PiiDetector.Cloudlare.check_pii_with_ai(text_message) do
      PiiDetector.Slack.send_message(response, event, source)
    else
      {:error, reason} ->
        # Handle the error case
        IO.puts("Error checking PII: #{reason}")
        {:error, reason}
    end

    # Handle the text message here
    # For example, you can log it or send it to another service
    IO.puts("Received text message: #{text_message}")
    {:ok, text_message}
  end

  defp build_text_for_notion(page) do
    Enum.reduce(page["properties"]["Ticket description"]["title"], "", fn map, acc ->
      acc <> map["plain_text"] <> " "
    end)
    |> String.trim()
  end
end
