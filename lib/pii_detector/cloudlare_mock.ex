defmodule PiiDetector.CloudlareMock do
  def check_pii_with_ai(_text_message) do
    {:ok, "yes"}
  end
end
