defmodule WebtritAdapterWeb.Api.V1.ErrorJSON do
  def error(%{code: code}) do
    %{
      code: code
    }
  end
end
