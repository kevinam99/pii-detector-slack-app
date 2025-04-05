defmodule PiiDetectorWeb.WebhookController do
  use PiiDetectorWeb, :controller

  require Logger

  @slack_app_id Application.compile_env!(:pii_detector, :slack)[:app_id]
  @slack_verification_token Application.compile_env!(:pii_detector, :slack)[:verification_token]
  @slack_module Application.compile_env!(:pii_detector, :slack_module)
  @notion_module Application.compile_env!(:pii_detector, :notion_module)
  @cloudflare_module Application.compile_env!(:pii_detector, :cloudflare_module)

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

  # handle other message types
  # Problem: the urls received from the webhook for multimedia files don't allow downloading files programmatically to check their contents
  def slack_webhook(
        conn,
        %{
          "api_app_id" => @slack_app_id,
          "token" => @slack_verification_token,
          "event" => %{"files" => files} = event
        } = params
      )
      when is_list(files) do
    IO.inspect(params, label: "params", limit: :infinity)

    with nil <- event["bot_id"],
         file when is_map(file) <- List.first(files),
         {:file, filetype} <- {:file, file["filetype"]},
         file_url = file["permalink"],
         handle_file(file_url, filetype, :slack) do
      json(conn, %{})
    else
      _ -> json(conn, %{})
    end
  end

  def slack_webhook(conn, _params), do: json(conn, %{})

  def notion_webhook(conn, %{"verification_token" => token}) do
    Logger.info(token, label: "Notion Webhook Token")
    json(conn, %{challenge: "challenge"})
  end

  def notion_webhook(conn, %{"type" => "page.created"} = params) do
    # Handle the Notion webhook event here

    with {:ok, page} <- @notion_module.fetch_page(params["entity"]["id"]),
         {:ok, user_email} <- @notion_module.fetch_user_email(page["created_by"]["id"]),
         {:ok, slack_user} <- @slack_module.lookup_user_by_email(user_email),
         text = build_text_for_notion(page) do
      handle_text_message(text, %{"user" => slack_user["id"], "text" => text}, :notion)
    else
      {:error, reason} ->
        # Handle the error case
        Logger.error("Error checking PII: #{reason}")
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

    with {:ok, response} <- @cloudflare_module.check_pii_with_ai(text_message) do
      @slack_module.send_message(response, event, source)
    else
      {:error, reason} ->
        # Handle the error case
        Logger.info("Error checking PII: #{reason}")
        {:error, reason}
    end

    # Handle the text message here
    # For example, you can log it or send it to another service
    Logger.info("Received text message: #{text_message}")
    {:ok, text_message}
  end

  defp handle_file(file_url, "pdf", _source) do
    @slack_module.fetch_file(file_url)

    # with {:ok, response} <- @cloudflare_module.check_pii_with_ai(file_url) do
    #   @slack_module.send_message(response, %{"text" => filetype}, source)
    # else
    #   {:error, reason} ->
    #     # Handle the error case
    #     Logger.info("Error checking PII: #{reason}")
    #     {:error, reason}
    # end

    # Handle the file here
    # For example, you can log it or send it to another service
    Logger.info("Received file URL: #{file_url}")
    {:ok, file_url}
  end

  defp build_text_for_notion(page) do
    Enum.reduce(page["properties"]["Ticket description"]["title"], "", fn map, acc ->
      acc <> map["plain_text"] <> " "
    end)
    |> String.trim()
  end
end
