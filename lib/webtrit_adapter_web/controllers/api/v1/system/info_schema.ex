defmodule WebtritAdapterWeb.Api.V1.System.InfoSchema do
  require OpenApiSpex
  require OpenApiSpexExt

  alias OpenApiSpex.Schema
  alias WebtritAdapterWeb.Api.V1.SupportedFunctionality

  defmodule ShowResponse do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        name: %Schema{type: :string},
        version: %Schema{type: :string},
        supported: %Schema{
          type: :array,
          description: """
          A list of supported functionalities by the **Adaptee**.

          Possible functionalities values:
          #{Enum.map_join(SupportedFunctionality.all_values(), "\n", fn value -> "* `#{value}` - #{SupportedFunctionality.value_description(value)}" end)}
          """,
          items: %Schema{
            type: :string,
            enum: SupportedFunctionality.all_values()
          }
        },
        custom: %Schema{
          type: :object,
          description: """
          Additional custom key-value pairs providing extended information about
          the **Adaptee** and/or its environment.
          """,
          additionalProperties: %Schema{
            type: :string
          }
        }
      },
      required: [:name, :version, :supported],
      example: """
      {
        "name": "WebTrit Adapter",
        "version": "1.0.0",
        "supported": [
          "otpSignin",
          "passwordSignin",
          "recordings",
          "callHistory"
        ],
        "custom": {
          "PBX version": "7.0.0"
        }
      }
      """
    })
  end
end
