defmodule WebtritAdapterWeb.Api.V1.User.HistorySchema do
  require OpenApiSpex
  require OpenApiSpexExt

  alias OpenApiSpex.Schema
  alias WebtritAdapterWeb.Api.V1.CommonSchema

  defmodule IndexResponse do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        items: %Schema{
          type: :array,
          items: CommonSchema.CDRInfo
        },
        pagination: CommonSchema.Pagination
      }
    })
  end
end
