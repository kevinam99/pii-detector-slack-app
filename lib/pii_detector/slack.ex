defmodule PiiDetector.Slack do
  require Logger

  def send_message("yes", event, source) do
    Logger.info("PII detected in message: #{event["text"]}")

    message =
      case source do
        :slack -> "PII detected in your message"
        :notion -> "PII detected in your Notion ticket"
      end

    blocks =
      [
        %{
          "type" => "section",
          "text" => %{
            "type" => "mrkdwn",
            "text" => "*#{message}*"
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
end
