defmodule PiiDetectorWeb.WebhookController do
  use PiiDetectorWeb, :controller

  require Logger

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
          "api_app_id" => app_id,
          "token" => verification_token,
          "event" => %{"blocks" => blocks} = event
        } = params
      )
      when is_list(blocks) do
    slack_config = get_slack_config()
    ^app_id = slack_config[:app_id]
    ^verification_token = slack_config[:verification_token]

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
         {:ok, permalink} <- @slack_module.fetch_message_permalink(event["channel"], event["ts"]),
         handle_text_message(text_message, Map.put(event, "url", permalink), :slack) do
      json(conn, %{})
    else
      _ -> json(conn, %{})
    end
  rescue
    e ->
      IO.inspect(params)
      Logger.error("Error in slack_webhook: #{inspect(e)}")
      json(conn, %{})
  end

  # handle other message types
  # Problem: the urls received from the webhook for multimedia files don't allow downloading files programmatically to check their contents
  def slack_webhook(
        conn,
        %{
          "api_app_id" => app_id,
          "token" => verification_token,
          "event" => %{"files" => files} = event
        } = params
      )
      when is_list(files) do
    IO.inspect(params, label: "params", limit: :infinity)
    slack_config = get_slack_config()
    ^app_id = slack_config[:app_id]
    ^verification_token = slack_config[:verification_token]

    with nil <- event["bot_id"],
         file when is_map(file) <- List.first(files),
         {:file, filetype} <- {:file, file["filetype"]},
         file_url = file["url_private_download"],
         handle_file(event, file_url, filetype, :slack) do
      json(conn, %{})
    else
      _ -> json(conn, %{})
    end
  rescue
    e ->
      Logger.error("Error in slack_webhook: #{inspect(e)}")
      json(conn, %{})
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
      handle_text_message(
        text,
        %{"user" => slack_user["id"], "text" => text, "url" => page["url"]},
        :notion
      )
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

  defp handle_file(event, file_url, "pdf", _source) do
    {:ok, file} = @slack_module.fetch_file(file_url)
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

  # handle image files
  defp handle_file(event, file_url, filetype, _source) when filetype in ["jpg", "jpeg", "png"] do
    # Handle the file here

    with {:ok, image} <- @slack_module.fetch_file(file_url),
         {:ok, response} <- PiiDetector.Huggingface.check_pii_with_ai_in_image(image) do
      @slack_module.send_message(response, event, :slack)
    else
      {:error, reason} ->
        # Handle the error case
        Logger.info("Error checking PII: #{reason}")
        {:error, reason}
    end
  end

  defp build_text_for_notion(page) do
    Enum.reduce(page["properties"]["Ticket description"]["title"], "", fn map, acc ->
      acc <> map["plain_text"] <> " "
    end)
    |> String.trim()
  end

  defp get_slack_config() do
    Application.fetch_env!(:pii_detector, :slack)
  end
end
