ExUnit.start()

defmodule TestHelper do
  def slack_webhook do
    %{
      "api_app_id" => "A08M42LM8CR",
      "authorizations" => [
        %{
          "enterprise_id" => nil,
          "is_bot" => false,
          "is_enterprise_install" => false,
          "team_id" => "T08LVE6032Q",
          "user_id" => "U08LVE609QC"
        }
      ],
      "context_enterprise_id" => nil,
      "context_team_id" => "T08LVE6032Q",
      "event" => %{
        "blocks" => [
          %{
            "block_id" => "gB9fq",
            "elements" => [
              %{
                "elements" => [%{"text" => "test", "type" => "text"}],
                "type" => "rich_text_section"
              }
            ],
            "type" => "rich_text"
          }
        ],
        "channel" => "C08LVE63Q9J",
        "channel_type" => "channel",
        "client_msg_id" => "3dab1627-6d71-41c3-81f1-6821df92604b",
        "event_ts" => "1743788636.650709",
        "team" => "T08LVE6032Q",
        "text" => "test",
        "ts" => "1743788636.650709",
        "type" => "message",
        "user" => "U08LVE609QC"
      },
      "event_context" =>
        "4-eyJldCI6Im1lc3NhZ2UiLCJ0aWQiOiJUMDhMVkU2MDMyUSIsImFpZCI6IkEwOE00MkxNOENSIiwiY2lkIjoiQzA4TFZFNjNROUoifQ",
      "event_id" => "Ev08LWKJFRN0",
      "event_time" => 1_743_788_636,
      "is_ext_shared_channel" => false,
      "team_id" => "T08LVE6032Q",
      "token" => "Xxel3XUM6IceouEjkbKjG6mL",
      "type" => "event_callback"
    }
  end

  def notion_webhook do
    %{
      "id" => "17ec1404-b9cb-450a-ae8f-2732fe61fe62",
      "timestamp" => "2025-04-04T22:17:27.029Z",
      "workspace_id" => "5417d94b-a30c-4702-b37b-c6e8ed9b5ce3",
      "workspace_name" => "Kevin A Mathew’s Notion",
      "subscription_id" => "1cbd872b-594c-81bc-8040-0099e3cec788",
      "integration_id" => "1cbd872b-594c-8075-a82f-0037f7bde673",
      "authors" => [
        %{
          "id" => "1b7d872b-594c-818f-b506-00023b14fe68",
          "type" => "person"
        }
      ],
      "attempt_number" => 3,
      "entity" => %{
        "id" => "1cb94e9e-6882-80c7-b984-d1bceade8b57",
        "type" => "page"
      },
      "type" => "page.created",
      "data" => %{
        "parent" => %{
          "id" => "1cb94e9e-6882-80fa-baa2-e85566a3592d",
          "type" => "database"
        }
      }
    }
  end
end
