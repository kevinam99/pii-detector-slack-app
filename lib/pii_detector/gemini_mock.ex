defmodule PiiDetector.GeminiMock do
  def check_pii_in_file(_file, _mime_type) do
    {:ok, "yes"}
  end
end
