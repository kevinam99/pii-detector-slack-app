defmodule PiiDetector.Notion do
  def fetch_page(page_id) do
    url = "https://api.notion.com/v1/pages/#{page_id}"
    api_token = Application.get_env(:pii_detector, :notion)[:api_token]

    headers = [
      {"Authorization", "Bearer #{api_token}"},
      {"Notion-Version", "2022-06-28"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Error: #{status_code} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end

  def fetch_user_email(user_id) do
    url = "https://api.notion.com/v1/users/#{user_id}"
    api_token = Application.get_env(:pii_detector, :notion)[:api_token]

    headers = [
      {"Authorization", "Bearer #{api_token}"},
      {"Notion-Version", "2022-06-28"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{"object" => "user"} = user = Jason.decode!(body)
        {:ok, user["person"]["email"]}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Error: #{status_code} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end
end
