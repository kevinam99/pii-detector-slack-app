defmodule PiiDetector.Cloudlare do
  def check_pii_with_ai(text_message) when is_binary(text_message) do
    url =
      "https://api.cloudflare.com/client/v4/accounts/2532c238321714c590816151bbbb15e5/ai/run/@cf/meta/llama-3-8b-instruct"

    api_token = Application.fetch_env!(:pii_detector, :cloudflare)[:api_token]

    messages =
      [
        %{
          "role" => "system",
          "content" =>
            "You are a PII detector. You will be given a text message. You only have to tell me if the text message contains PII or not. You will only respond with 'yes' or 'no'."
        },
        %{
          "role" => "user",
          "content" => text_message
        }
      ]

    body =
      %{
        "messages" => messages
      }
      |> Jason.encode!()

    headers = [{"Authorization", "Bearer #{api_token}"}, {"Content-Type", "application/json"}]

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{"result" => result} = Jason.decode!(body)

        # responds with 'yes' or 'no' if the text message contains PII or not
        {:ok, result["response"] |> String.downcase()}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Error: #{status_code} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end

  def extract_text_from_image(image) do
    url =
      "https://api.cloudflare.com/client/v4/accounts/2532c238321714c590816151bbbb15e5/ai/run/@cf/unum/uform-gen2-qwen-500m"

    api_token = Application.fetch_env!(:pii_detector, :cloudflare)[:api_token]

    body =
      %{
        "image" => :binary.bin_to_list(image),
        "prompt" => "Find the text in the image and return it"
      }
      |> Jason.encode!()

    headers = [{"Authorization", "Bearer #{api_token}"}, {"Content-Type", "application/json"}]

    case HTTPoison.post(url, body, headers, recv_timeout: 30000, timeout: 30000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{"result" => result} = Jason.decode!(body) |> IO.inspect()

        # responds with 'yes' or 'no' if the text message contains PII or not
        {:ok, result["description"] |> String.trim()}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Error: #{status_code} - #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end
end
