defmodule WebtritAdapterWeb.Api.V1.ErrorJSON do
  def error(%{code: code, details: nil}) do
    %{
      code: code
    }
  end

  def error(%{code: code, details: details}) do
    %{
      code: code,
      details: details
    }
  end

  def error(%{code: code}), do: error(%{code: code, details: nil})
end
