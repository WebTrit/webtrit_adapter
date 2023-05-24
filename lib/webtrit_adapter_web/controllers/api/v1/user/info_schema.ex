defmodule WebtritAdapterWeb.Api.V1.User.InfoSchema do
  require OpenApiSpex
  require OpenApiSpexExt

  alias OpenApiSpex.Schema
  alias WebtritAdapterWeb.Api.V1.CommonSchema

  defmodule ShowResponse do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        status: %Schema{
          type: :string,
          description: """
          The user's account status.

          * `active`, the user is in an active state and has full access to all functionality
            (this is the default value and will be assumed if this property is not specified)
          * `limited`, indicates a condition of restricted functionality access
            (while sign-in and API calls may be allowed, call capabilities could
            be partially or fully restricted)
          * `blocked`, denotes a state in which the user is blocked, and as a result,
            client applications won't be able to sign in and will be signed out if
            previously signed in
            (API calls might be partially available, but call capabilities are fully
            restricted)

          Note that the number of possible values may be expanded in the future.
          """,
          enum: [
            :active,
            :limited,
            :blocked
          ],
          default: :active
        },
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
