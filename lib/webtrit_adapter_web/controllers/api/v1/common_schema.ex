defmodule WebtritAdapterWeb.Api.V1.CommonSchema do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  defmodule ErrorResponse do
    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        message: %Schema{
          type: :string,
          description: "Description of the error."
        },
        code: %Schema{
          type: :string,
          description: "Unique error code identifier."
        },
        details: %Schema{
          type: :array,
          description: """
          Additional details related to the error code, which depend on the specific error.
          """,
          items: %Schema{
            oneOf: [
              %Schema{
                type: :object,
                description: """
                Provided for the `validation_error` error code, containing detailed
                information about the invalid field.
                """,
                properties: %{
                  path: %Schema{type: :string},
                  reason: %Schema{type: :string}
                }
              },
              %Schema{
                type: :object,
                description: """
                Any other error-related data.
                """
              }
            ]
          }
        }
      },
      required: [:code]
    })
  end

  def error_response(enum) do
    %Schema{
      allOf: [
        ErrorResponse,
        %Schema{
          type: :object,
          properties: %{
            code: %Schema{
              enum: enum
            }
          }
        }
      ]
    }
  end

  defmodule BinaryResponse do
    OpenApiSpex.schema(%{
      type: :string,
      format: :binary
    })
  end

  defmodule Pagination do
    OpenApiSpex.schema(%{
      type: :object,
      description: "Information about pagination of results.",
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
          description: "Number of items presented per page.",
          example: 100
        },
        items_total: %Schema{
          type: :integer,
          minimum: 0,
          description: """
          Total number of items found in filtered result set.
          If no filters are provided, this represents total number
          of items available.
          """,
          example: 1000
        }
      }
    })
  end

  defmodule UserId do
    OpenApiSpex.schema(%{
      type: :string,
      description: """
      A primary unique identifier of the user on the **Adaptee**.

      This identifier is crucial for the proper functioning of **WebTrit Core**, as it is used
      to store information such as push tokens and other relevant data associated to the user.

      The **Adaptee** must consistently return the same `UserId` for the same user,
      regardless of the `UserRef` used for sign-in.
      """,
      example: "123456789abcdef0123456789abcdef0"
    })
  end

  defmodule UserRef do
    OpenApiSpex.schema(%{
      type: :string,
      description: """
      A reference identifier of the user on the **Adaptee**

      This identifier is entered by the user in client applications and passed
      via **WebTrit Core** to the **Adaptee** for sign-in purposes.

      The identifier can be a phone number or any other attribute associated
      with the user. When the same user is accessed using different references,
      it is crucial to ensure that the same `UserId` is assigned to this user.
      """,
      example: "1234567890"
    })
  end

  defmodule OtpId do
    OpenApiSpex.schema(%{
      type: :string,
      description: """
      Unique identifier of the OTP request on the **Adapter** and/or **Adaptee** side.

      Note: This ID is NOT the code that the user will enter. It serves
      to match the originally generated OTP with the one provided by the user.
      """,
      example: "12345678-9abc-def0-1234-56789abcdef0"
    })
  end

  defmodule AccessToken do
    OpenApiSpex.schema(%{
      type: :string,
      description: """
      A short-lived token that grants access to the API resources.

      It must be included as an Authorization header in the format `Bearer {access_token}` with each API request.
      The `access_token` has an expiration date, so it needs to be refreshed periodically using a `refresh_token`
      to maintain uninterrupted access to the API without requiring the user to manually sign in again.

      Please note that the `access_token` should be kept secure and not shared, as it grants access to the user's
      data and actions within the API.
      """
    })
  end

  defmodule RefreshToken do
    OpenApiSpex.schema(%{
      type: :string,
      description: """
      A single-use token for refreshing the API session and obtaining a new `access_token`.

      When the current `access_token` is close to expiration or has already expired, the
      `refresh_token` can be exchanged for a new `access_token`, ensuring uninterrupted access
      to the API without requiring the user to manually sign in again.

      Please note that each `refresh_token` can only be used once, and a new `refresh_token`
      will be issued along with the new `access_token`.
      """
    })
  end

  defmodule CallRecordingId do
    OpenApiSpex.schema(%{
      type: :string,
      description: """
      A unique identifier for a call recording, used to reference the recorded media of a specific call.
      """
    })
  end

  defmodule CDRInfo do
    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        callee: %Schema{
          type: :string,
          description: "The phone number of the called party (recipient of the call, CLD).",
          example: "14155551234"
        },
        caller: %Schema{
          type: :string,
          description: "The phone number of the calling party (originator of the call, CLI).",
          example: "0001"
        },
        direction: %Schema{
          type: :string,
          description: "Indicates the call direction.",
          enum: [
            :incoming,
            :outgoing
          ]
        },
        status: %Schema{
          type: :string,
          description: "Indicates the call status.",
          enum: [
            :accepted,
            :declined,
            :missed,
            :error
          ]
        },
        disconnect_reason: %Schema{
          type: :string,
          description: "Describes the reason for the call disconnection.",
          example: "Caller hangup"
        },
        connect_time: %Schema{
          type: :string,
          format: :"date-time",
          description: "Datetime of the call connection in ISO format.",
          example: "2023-01-01T09:00:00Z"
        },
        disconnect_time: %Schema{
          type: :string,
          format: :"date-time",
          description: "Datetime of the call disconnection in ISO format.",
          example: "2023-01-01T09:01:00Z"
        },
        duration: %Schema{
          type: :integer,
          description: "Call duration (in seconds), 0 for failed calls.",
          example: 60
        },
        recording_id: CallRecordingId
      },
      required: [:callee, :caller, :direction, :status]
    })
  end

  defmodule SipServer do
    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        host: %Schema{
          type: :string,
          description: "The SIP server address, which can be either a hostname or an IP address.",
          example: "sip.webtrit.com"
        },
        port: %Schema{
          type: :integer,
          description: "The port on which the SIP server listens for incoming requests.",
          example: 5060
        },
        force_tcp: %Schema{
          type: :boolean,
          description: "If set to true, forces the use of TCP for SIP messaging.",
          example: false
        }
      },
      required: [:host]
    })
  end

  defmodule SipInfo do
    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        login: %Schema{
          type: :string,
          description: "The username to be used in SIP requests.",
          example: "14155551234"
        },
        password: %Schema{
          type: :string,
          description: "The password for the SIP account.",
          example: "strong_password"
        },
        sip_server: SipServer,
        registration_server: SipServer,
        display_name: %Schema{
          type: :string,
          description: """
          The visible identification of the caller to be included in the SIP request.
          This will be shown to the called party as the caller's name. If not provided,
          the `display_name` will be populated with the `login`.
          """,
          example: "Thomas A. Anderson"
        }
      },
      required: [:login, :password, :sip_server]
    })
  end

  defmodule SipStatus do
    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        display_name: %Schema{
          type: :string,
          description: "The user's display name for SIP calls.",
          example: "Annabelle Black"
        },
        status: %Schema{
          type: :string,
          description: "The current registration status of the user on the SIP server.",
          enum: [
            :unknown,
            :registered,
            :notregistered
          ]
        }
      },
      required: [:display_name, :status]
    })
  end

  defmodule Balance do
    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        balance_type: %Schema{
          type: :string,
          description: """
          Meaning of the balance figure for this user.

          * `inapplicable` means the **Adaptee** does not handle
            billing and does not have the balance data.
          * `prepaid` means the number reflects the funds that
            the user has available for spending.
          * `postpaid` means the balance reflects the amount of
            previously accumulated charges (how much the user
            owes - to be used in conjunction with a `credit_limit`).
          """,
          enum: [
            :unknown,
            :inapplicable,
            :prepaid,
            :postpaid
          ]
        },
        amount: %Schema{
          type: :number,
          description: "The user's current balance.",
          example: "50.00"
        },
        credit_limit: %Schema{
          type: :number,
          description: "The user's credit limit (if applicable).",
          example: "100.00"
        },
        currency: %Schema{
          type: :string,
          description: "Currency symbol or name in ISO 4217:2015 format (e.g. USD).",
          default: "$",
          minimum: 1,
          maximum: 3,
          example: "$"
        }
      }
    })
  end

  defmodule Numbers do
    OpenApiSpex.schema(%{
      description: "Phone numbers associated with the user.",
      type: :object,
      properties: %{
        main: %Schema{
          type: :string,
          description: """
          The user's primary phone number. It is strongly suggested
          to use the full number, including the country code
          (also known as the E.164 format).
          """,
          example: "14155551234"
        },
        ext: %Schema{
          type: :string,
          description: """
          The user's extension number (short dialing code) within the **Adaptee**.
          """,
          example: "0001"
        },
        additional: %Schema{
          type: :array,
          description: """
          A list of other phone numbers associated with the user. This may
          include extra phone numbers that the user purchased (also called
          direct-inward-dials or DID) to ring on their VoIP phone,
          and other numbers that can be used to identify them in the
          address book of others (e.g. their mobile number).
          """,
          items: %Schema{
            type: :string
          },
          example: ["380441234567", "34911234567"]
        }
      },
      required: [:main]
    })
  end

  defmodule Contact do
    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        sip: SipStatus,
        numbers: Numbers,
        first_name: %Schema{
          type: :string,
          description: "The user's first name.",
          example: "Annabelle"
        },
        last_name: %Schema{
          type: :string,
          description: "The user's last name.",
          example: "Black"
        },
        email: %Schema{
          type: :string,
          format: :email,
          description: "The user's email address.",
          example: "a.black@matrix.com"
        },
        company_name: %Schema{
          type: :string,
          description: "The name of the company the user is associated with.",
          example: "Matrix"
        }
      }
    })
  end
end
