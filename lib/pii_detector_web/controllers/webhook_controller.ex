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
        } = params
      )
      when is_list(blocks) do
    IO.inspect(params, limit: :infinity)

    with block when is_map(block) <- List.first(blocks),
         {:rich_text, true} <- {:rich_text, block["type"] == "rich_text"},
         text_message = event["text"],
         #  text_message =
         #    List.first(block["elements"])
         #    |> Map.get("elements")
         #    |> Enum.filter(fn map -> map["type"] == "text" end)
         #    |> List.first(%{})
         #    |> Map.get("text"),
         handle_text_message(text_message, event) do
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
    IO.inspect(params, label: "Notion Webhook Event")

    with 
    json(conn, %{})
  end

  defp handle_text_message(nil, _event) do
    # Handle the case where there is no text message
    nil
  end

  defp handle_text_message(text_message, event) when is_binary(text_message) do
    text_message = String.trim(text_message)

    with {:ok, response} <- PiiDetector.Cloudlare.check_pii_with_ai(text_message) do
      PiiDetector.Slack.send_message(response, event)
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
end
