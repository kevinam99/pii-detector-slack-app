defmodule PiiDetector.Slack do
  require Logger

  def send_message("yes", event) do
    Logger.info("PII detected in message: #{event["text"]}")

    blocks =
      [
        %{
          "type" => "section",
          "text" => %{
            "type" => "mrkdwn",
            "text" => "*PII detected in your message*"
          }
        },
        %{
          "type" => "section",
          "text" => %{
            "type" => "mrkdwn",
            "text" => "The following message has been deleted \n```#{event["text"]}```"
          }
        }
      ]
      |> Jason.encode!()

    Slack.Web.Chat.delete(event["channel"], event["ts"])

    Slack.Web.Chat.post_message(event["user"], "PII detected in your message", %{blocks: blocks})
  end

  def send_message("no", _), do: {:ok, "no_pii"}


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
