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
        pagination: %Schema{
          type: :object,
          description: "Pagination information.",
          properties: %{
            page: %Schema{
              type: :integer,
              minimum: 1,
              description: "Current page number.",
              example: 1
            },
            items_per_page: %Schema{
              type: :integer,
              minimum: 1,
              description: "Number of items per page.",
              example: 100
            },
            items_total: %Schema{
              type: :integer,
              minimum: 0,
              description: """
              Total number of CDRs within the selected time period
              or within the entire history if no time period is provided.
              """,
              example: 1000
            }
          }
        }
      }
    })
  end
end
