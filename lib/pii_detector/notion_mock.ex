defmodule PiiDetector.NotionMock do
  def fetch_page(page_id) do
    {:ok,
     %{
       "archived" => true,
       "cover" => nil,
       "created_by" => %{
         "id" => "U12345678",
         "object" => "user"
       },
       "created_time" => "2025-04-04T22:11:00.000Z",
       "icon" => nil,
       "id" => page_id,
       "in_trash" => true,
       "last_edited_by" => %{
         "id" => "U12345678",
         "object" => "user"
       },
       "last_edited_time" => "2025-04-04T22:17:00.000Z",
       "object" => "page",
       "parent" => %{
         "database_id" => "1cb94e9e-6882-80fa-baa2-e85566a3592d",
         "type" => "database_id"
       },
       "properties" => %{
         "Ticket description" => %{
           "id" => "title",
           "title" => [
             %{
               "annotations" => %{
                 "bold" => false,
                 "code" => false,
                 "color" => "default",
                 "italic" => false,
                 "strikethrough" => false,
                 "underline" => false
               },
               "href" => nil,
               "plain_text" => "2now this is a message with pii ",
               "text" => %{
                 "content" => "2now this is a message with pii ",
                 "link" => nil
               },
               "type" => "text"
             },
             %{
               "annotations" => %{
                 "bold" => false,
                 "code" => true,
                 "color" => "default",
                 "italic" => false,
                 "strikethrough" => false,
                 "underline" => false
               },
               "href" => nil,
               "plain_text" => "123-45-6789",
               "text" => %{"content" => "123-45-6789", "link" => nil},
               "type" => "text"
             },
             %{
               "annotations" => %{
                 "bold" => false,
                 "code" => false,
                 "color" => "default",
                 "italic" => false,
                 "strikethrough" => false,
                 "underline" => false
               },
               "href" => nil,
               "plain_text" => " in notion",
               "text" => %{"content" => " in notion", "link" => nil},
               "type" => "text"
             }
           ],
           "type" => "title"
         }
       },
       "public_url" => nil,
       "request_id" => "4875abab-bb96-4131-bd7d-8a0df64dbf9e",
       "url" =>
         "https://www.notion.so/2now-this-is-a-message-with-pii-123-45-6789-in-notion-1cb94e9e688280ffaa42da7eef97b894"
     }}
  end

  def fetch_user_email(_user_id) do
    {:ok, "test@email.com"}
  end
end
