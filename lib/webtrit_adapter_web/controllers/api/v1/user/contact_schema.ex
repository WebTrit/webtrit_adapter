defmodule WebtritAdapterWeb.Api.V1.User.ContactSchema do
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
          items: CommonSchema.Contact
        }
      }
    })
  end
end
