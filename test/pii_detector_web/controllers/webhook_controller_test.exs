defmodule PiiDetectorWeb.WebhookControllerTest do
  use PiiDetectorWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "slack webhooks" do
    test "returns 200 for valid challenge", %{conn: conn} do
      params = %{"challenge" => "test_challenge"}
      conn = post(conn, "/api/slack-webhook", params)
      assert json_response(conn, 200) == %{"challenge" => "test_challenge"}
    end

    test "returns 200 for valid event", %{conn: conn} do
      params = %{
        "api_app_id" => Application.get_env(:pii_detector, :slack)[:app_id],
        "token" => Application.get_env(:pii_detector, :slack)[:verification_token],
        "event" => %{
          "blocks" => [
            %{
              "type" => "rich_text",
              "elements" => [
                %{
                  "type" => "rich_text_section",
                  "elements" => [
                    %{"type" => "text", "text" => "Hello World"}
                  ]
                }
              ]
            }
          ],
          "bot_id" => nil,
          "text" => "Hello World",
          "ts" => "1234567890.123456"
        }
      }

      conn = post(conn, "/api/slack-webhook", params)
      assert json_response(conn, 200) == %{}
    end
  end

  test "returns 200 for messages with files", %{conn: conn} do
    params = %{
      "api_app_id" => Application.get_env(:pii_detector, :slack)[:app_id],
      "token" => Application.get_env(:pii_detector, :slack)[:verification_token],
      "event" => %{
        "channel" => "C08LVA8",
        "files" => [
          %{
            "filetype" => "pdf",
            "id" => "F08RJ2173C5",
            "mimetype" => "application/pdf",
            "url_private_download" => "https://files.slack.com/file2_.pdf"
          }
        ],
        "ts" => "1746763397.418489",
        "user" => "U08LVE609QC"
      },
      "event_context" => "4NWQTgifQ",
      "event_id" => "Ev08RY6N"
    }

    conn = post(conn, "/api/slack-webhook", params)
    assert json_response(conn, 200) == %{}
  end

  describe "notion webhooks" do
    test "returns 200 for valid challenge", %{conn: conn} do
      params = %{"verification_token" => "test_token"}
      conn = post(conn, "/api/notion-webhook", params)
      assert json_response(conn, 200) == %{"challenge" => "challenge"}
    end

    test "returns 200 for valid page.created event", %{conn: conn} do
      params = TestHelper.notion_webhook()

      conn = post(conn, "/api/notion-webhook", params)
      assert json_response(conn, 200) == %{}
    end

    test "returns 200 for invalid event", %{conn: conn} do
      params = %{
        "type" => "invalid.event"
      }

      conn = post(conn, "/api/notion-webhook", params)
      assert json_response(conn, 200) == %{}
    end
  end
end
