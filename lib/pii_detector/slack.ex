defmodule PiiDetector.Slack do
  def call_slack("yes", event) do
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
            "text" => "```#{event["text"]}```"
          }
        }
      ]
      |> Jason.encode!()

    Slack.Web.Chat.delete(event["channel"], event["ts"])

    Slack.Web.Chat.post_message(event["user"], "PII detected in your message", %{blocks: blocks})
    |> IO.inspect()
  end

  def call_slack("no", _), do: {:ok, "no_pii"}
end
