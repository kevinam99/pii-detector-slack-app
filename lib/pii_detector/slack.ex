defmodule PiiDetector.Slack do
  require Logger

  def send_message("yes", event, source) do
    Logger.info("PII detected in message: #{event["text"]}")

    title =
      case source do
        :slack -> "PII detected in your message in your Slack channel"
        :notion -> "PII detected in your Notion ticket"
      end

    blocks =
      [
        %{
          "type" => "section",
          "text" => %{
            "type" => "mrkdwn",
            "text" => "*#{title}*"
          }
        },
        %{
          "type" => "section",
          "text" => %{
            "type" => "mrkdwn",
            "text" => "Please delete it <#{event["url"]}>."
          }
        },
        %{
          "type" => "section",
          "text" => %{
            "type" => "mrkdwn",
            "text" => "```#{event["text"]}```"
          }
        }
      ]
      |> Jason.encode!()

    IO.inspect({event["channel"], event["ts"]})
    delete_message(event["channel"], event["ts"]) |> IO.inspect()
    Slack.Web.Chat.post_message(event["user"], "", %{blocks: blocks})
  end

  def send_message("no", _, _), do: {:ok, "no_pii"}

  def lookup_user_by_email(email) do
    case Slack.Web.Users.lookup_by_email(email) do
      %{"ok" => true, "user" => user} = _resp ->
        {:ok, user}

      %{"ok" => false, "error" => "users_not_found"} = _resp ->
        {:error, "user not found"}

      _ ->
        {:error, "Unknown error"}
    end
  end

  def fetch_file(file_url) do
    case HTTPoison.get(file_url, follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.inspect(body, label: "File content")
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 302, body: body}} ->
        IO.inspect(body, label: "File content")
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Error: #{status_code} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end

  def fetch_message_permalink(channel_id, ts) when is_binary(ts) do
    case Slack.Web.Chat.get_permalink(channel_id, ts) do
      %{"ok" => true, "permalink" => permalink} ->
        {:ok, permalink}

      {:error, reason} ->
        {:error, reason}

      _ ->
        {:error, "No permalink found"}
    end
  end

  defp delete_message(channel, ts) do
    url = "https://slack.com/api/chat.delete"
    auth_token = Application.fetch_env!(:pii_detector, :slack)[:user_auth_token]

    headers = [
      {"Authorization", "Bearer #{auth_token}"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]
    body = %{
      "channel" => channel,
      "ts" => ts
    } |> Jason.encode!()
    IO.inspect({url, body, headers})


    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.info("Message deleted successfully")
        {:ok, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.info("Failed to delete message: #{reason}")
        {:error, reason}

      _ ->
        {:error, "Unknown error"}
    end
  end
end
