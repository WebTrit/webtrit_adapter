defmodule WebtritAdapterWeb.Api.V1.UserSchema do
  require OpenApiSpex
  require OpenApiSpexExt

  alias OpenApiSpex.Schema
  alias WebtritAdapterWeb.Api.V1.SessionSchema

  defmodule CreateRequest do
    OpenApiSpexExt.schema(%{
      type: :object,
      description: """
      This request creates a user using the provided information.

      It enables the implementation of the following sign-up scenarios with the **Adaptee**:
      * just create a user
      * initiate user creation and send an OTP to the user for provided information verification
      * create a user and automatically sign the user in

      The availability of the sign-up functionality is indicated by the `#{:signup}` value in the
      `supported` property of the `GeneralSystemInfoResponse`.
      """,
      example: %{
        email: "neo@matrix.com"
      }
    })
  end

  defmodule CreateResponse do
    OpenApiSpexExt.schema(%{
      oneOf: [
        %Schema{
          type: :object,
          description: "Any information returned by the **Adaptee** upon user creation."
        },
        SessionSchema.OtpCreateResponse,
        SessionSchema.Response
      ]
    })
  end
end
