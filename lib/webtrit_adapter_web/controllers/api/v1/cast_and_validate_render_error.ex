defmodule WebtritAdapterWeb.Api.V1.CastAndValidateRenderError do
  alias WebtritAdapterWeb.Api.V1.FallbackController

  def init(errors), do: errors

  def call(conn, errors) when is_list(errors) do
    validation_error_details =
      Enum.map(errors, fn error ->
        %{
          path: error.path |> Enum.join("."),
          reason: error.reason
        }
      end)

    FallbackController.call(conn, {:error, :unprocessable_entity, :validation_error, validation_error_details})
  end
end
