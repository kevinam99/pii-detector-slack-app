defmodule PiiDetector.Huggingface do
  def check_pii_with_ai_in_image(image) do
    api_key = Application.fetch_env!(:pii_detector, :huggingface_api_key)
    url = "https://router.huggingface.co/nebius/v1/chat/completions"
    headers = [{"Authorization", "Bearer #{api_key}"}, {"Content-Type", "application/json"}]

    body =
      %{
        model: "Qwen/Qwen2.5-VL-72B-Instruct",
        messages: [
          %{
            role: "user",
            content:
              "You are a PII detector. Given an image, you are required to scan it carefully to identify any PII. If you find the PII, say `yes`, else, say `no`. Reply with only `yes` or `no`",
            images: [
              :binary.bin_to_list(image)
            ]
          }
        ],
        max_tokens: 30,
        stream: false
      }
      |> Jason.encode!()

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body = Jason.decode!(body)

        response =
          Map.get(body, "choices")
          |> hd()
          |> then(& &1["message"]["content"])
          |> String.trim()
          |> String.downcase()
          |> String.replace(".", "")

        {:ok, response}

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        Logger.error("Calling huggingface ended with HTTP code #{status} and body #{body}")

        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison failed with reason #{reason}.")
        {:error, to_string(reason)}
    end
  end
end
