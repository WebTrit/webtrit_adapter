defmodule WebtritAdapterWeb.Api.V1.User.InfoSchema do
  require OpenApiSpex
  require OpenApiSpexExt

  alias OpenApiSpex.Schema
  alias WebtritAdapterWeb.Api.V1.CommonSchema

  defmodule ShowResponse do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        sip: CommonSchema.SipInfo,
        balance: CommonSchema.Balance,
        numbers: CommonSchema.Numbers,
        first_name: %Schema{
          type: :string,
          description: "The user's first name.",
          example: "Thomas"
        },
        last_name: %Schema{
          type: :string,
          description: "The user's last name.",
          example: "Anderson"
        },
        email: %Schema{
          type: :string,
          format: :email,
          description: "The user's email address.",
          example: "neo@matrix.com"
        },
        company_name: %Schema{
          type: :string,
          description: "The company the user is associated with.",
          example: "Matrix"
        },
        time_zone: %Schema{
          type: :string,
          description: """
          The preferred time zone for the user's displayed time values
          (see [time zones list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)).
          If not provided, the **WebTrit Core** server time zone is used.
          """,
          example: "Europe/Kyiv"
        }
      },
      required: [:sip]
    })
  end
end
