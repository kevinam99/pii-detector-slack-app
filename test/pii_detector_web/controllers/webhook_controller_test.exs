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
          "text" => "Hello World"
        }
      }

      conn = post(conn, "/api/slack-webhook", params)
      assert json_response(conn, 200) == %{}
    end
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
