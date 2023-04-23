defmodule WebtritAdapterWeb.Api.V1.SessionSchema do
  require OpenApiSpex
  require OpenApiSpexExt

  alias OpenApiSpex.Schema
  alias WebtritAdapterWeb.Api.V1.CommonSchema

  defmodule OtpCreateUserRefRequest do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        user_ref: CommonSchema.UserRef
      },
      required: [:user_ref],
      description: """
      This request generates an OTP using the provided reference.
      """
    })
  end

  defmodule OtpCreateUserEmailRequest do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        user_email: CommonSchema.UserEmail
      },
      required: [:user_email],
      description: """
      This request generates an OTP using the provided email address.

      It enables the possibility to implement of sign-in and sign-up functionalities with the **Adaptee**.

      If the **Adaptee** supports user creation or initialization,
      a new user can be created if they do not exist yet. The availability of
      the sign-up functionality is indicated by the `#{:signup}` value in the
      `supported` property of the `GeneralSystemInfoResponse`.
      """
    })
  end

  defmodule OtpCreateRequest do
    OpenApiSpexExt.schema(%{
      oneOf: [
        OtpCreateUserRefRequest,
        OtpCreateUserEmailRequest
      ]
    })
  end

  defmodule OtpCreateResponse do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        otp_id: CommonSchema.OtpId,
        delivery_channel: %Schema{
          type: :string,
          enum: [:email, :sms, :call, :other],
          description: """
          Specifies the channel used to deliver the OTP to the user
          (e.g., email, SMS, call, or other). This information helps guide the
          user on where to find the OTP.
          """
        },
        delivery_from: %Schema{
          type: :string,
          description: """
          Identifies the sender of the OTP, making it easier for the user to
          locate the correct message. Depending on the `delivery_channel`, this
          value may be an email address, phone number, or a description of an
          alternative method. In the case of email, if the message is marked as
          spam, the user can add this address to a whitelist for future
          reference.
          """
        }
      },
      required: [:otp_id]
    })
  end

  defmodule OtpVerifyRequest do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        otp_id: CommonSchema.OtpId,
        code: %Schema{
          type: :string,
          description: """
          Code (one-time-password) that the end-user receives from
          the hosted PBX system or BSS via email/SMS and then uses in
          application to confirm his/her identity and login.
          """
        }
      },
      required: [:otp_id, :code]
    })
  end

  defmodule CreateRequest do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        login: %Schema{
          type: :string,
          description: "User's `login` on the hosted PBX system / BSS."
        },
        password: %Schema{
          type: :string,
          description: "User's `password` on the hosted PBX system / BSS."
        }
      },
      required: [:login, :password]
    })
  end

  defmodule UpdateRequest do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        refresh_token: CommonSchema.RefreshToken
      },
      required: [:refresh_token]
    })
  end

  defmodule Response do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        user_id: CommonSchema.UserId,
        access_token: %Schema{
          type: :string,
          description: """
          The `access_token` to be used in subsequent API
          requests on behalf of the `user` (by default it is
          placed in the bearer auth HTTP header).
          """
        },
        refresh_token: CommonSchema.RefreshToken
      },
      required: [:user_id, :access_token, :expires_at]
    })
  end
end
