defmodule PiiDetector.Notion do
  require Logger

  def fetch_page(page_id) do
    url = "https://api.notion.com/v1/pages/#{page_id}"
    api_token = Application.fetch_env!(:pii_detector, :notion)[:api_token]

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
    api_token = Application.fetch_env!(:pii_detector, :notion)[:api_token]

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

  def delete_page(page_id) do
    url = "https://api.notion.com/v1/blocks/#{page_id}/"
    api_token = Application.fetch_env!(:pii_detector, :notion)[:api_token]

    headers = [
      {"Authorization", "Bearer #{api_token}"},
      {"Notion-Version", "2022-06-28"}
    ]

    case HTTPoison.delete(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.info("Deleted Notion page with id #{page_id}")
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Error: #{status_code} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end

  def fetch_page_content(page_id) do
    url = "https://api.notion.com/v1/blocks/#{page_id}/children"
    api_token = Application.fetch_env!(:pii_detector, :notion)[:api_token]

    headers = [
      {"Authorization", "Bearer #{api_token}"},
      {"Notion-Version", "2022-06-28"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)["results"]}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Error: #{status_code} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end

  def fetch_file_url_from_page_content([]), do: {:ok, nil}

  def fetch_file_url_from_page_content(page_content) do
    block =
      Enum.find(page_content, fn block -> block["type"] == "image" or block["type"] == "pdf" end)

    case block do
      %{"type" => "image", "image" => %{"file" => %{"url" => url}} = _} = _ ->
        {:ok, url}

      %{"type" => "pdf", "pdf" => %{"file" => %{"url" => url}} = _} = _ ->
        {:ok, url}

      _ ->
        {:ok, nil}
    end
  end

  def fetch_file_and_content_type(file_url) when is_binary(file_url) do
    case HTTPoison.get(file_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        content_type =
          headers
          |> Enum.find(fn {key, _} -> key == "Content-Type" end)
          |> elem(1)

        {:ok, body, content_type}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Error: #{status_code} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end
end
