defmodule PiiDetector.Gemini do
  @moduledoc """
  A module for interacting with the Gemini API.
  """

  def check_pii_in_file(file, mime_type) do
    url = fetch_google_url()

    headers = [
      {"Content-Type", "application/json"}
    ]

    contents = [
      %{
        parts: [
          %{
            inline_data: %{
              mime_type: mime_type,
              data: Base.encode64(file, case: :lower)
            }
          },
          %{
            text:
              "Does this file contain personally identifiable information (PII)? Reply with \"yes\" if it does or \"no\" if it doesn't"
          }
        ]
      }
    ]

    body = %{contents: contents} |> Jason.encode!()

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        [%{"finishReason" => "STOP", "content" => %{"parts" => parts}}] =
          Jason.decode!(body)["candidates"]

        response =
          Enum.at(parts, 0)["text"]
          |> String.downcase()
          |> String.trim()
          |> String.replace(".", "")

        {:ok, response}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Error: #{status_code} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end

  defp fetch_google_url() do
    api_key = Application.fetch_env!(:pii_detector, :google_ai_api_key)
    model = Application.fetch_env!(:pii_detector, :google_ai_model)

    "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=#{api_key}"
  end
end
