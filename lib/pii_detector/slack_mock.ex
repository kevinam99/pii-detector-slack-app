defmodule PiiDetector.SlackMock do
  require Logger

  def send_message("yes", _event, _source) do
    {:ok, %{}}
  end

  def send_message("no", _, _), do: {:ok, "no_pii"}

  def lookup_user_by_email(_email) do
    {:ok, %{"email" => "test@email.com", "id" => "U12345678"}}
  end

  def fetch_file(_file_url) do
    {:ok, %{}}
  end
end
