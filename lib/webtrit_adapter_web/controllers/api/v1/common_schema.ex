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
        call_id: %Schema{
          type: :string,
          description: "The field serves as the unique identifier for each call record.",
          example: "b2YBUVAUT27eW4QmAd2yBSqG"
        },
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
            :outgoing,
            :forwarded
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
        }
      },
      required: [:host]
    })
  end

  defmodule SipInfo do
    OpenApiSpex.schema(%{
      description: """
      The SIP information, where:
      * `sip_server` is the SIP server used to compose the SIP identity based on the `username`
      * `registrar_server` is the server where registration occurs; if not provided, the standard procedure defined by
        [RFC3263](https://tools.ietf.org/html/rfc3263) will be followed to locate the registrar
      * `outbound_proxy_server` is the outbound proxy to use; if provided, all future SIP requests will be routed through this proxy
      """,
      type: :object,
      properties: %{
        username: %Schema{
          type: :string,
          description: """
          The identity (typically a phone number but can be some other alphanumeric ID)
          that should be registered to SIP server to receive incoming calls.
          Usually it is also used as a username for SIP authorization of registrations (SIP REGISTER)
          and outgoing calls (SIP INVITE).
          """,
          example: "14155551234"
        },
        auth_username: %Schema{
          type: :string,
          description: """
          The username for SIP authorization;
          only needs to be populated if for a user it differs
          from his/her registration ID (which is normally a phone number) supplied in the `username` attribute.
          """,
          example: "thomas"
        },
        password: %Schema{
          type: :string,
          description: "The password for the SIP account.",
          example: "strong_password"
        },
        transport: %Schema{
          type: :string,
          description: "The transport protocol for SIP communication.",
          enum: [
            :UDP,
            :TCP,
            :TLS
          ]
        },
        sip_server: SipServer,
        registrar_server: SipServer,
        outbound_proxy_server: SipServer,
        display_name: %Schema{
          type: :string,
          description: """
          The visible identification of the caller to be included in the SIP request.
          This will be shown to the called party as the caller's name. If not provided,
          the `display_name` will be populated with the `username`.
          """,
          example: "Thomas A. Anderson"
        }
      },
      required: [:username, :password, :sip_server]
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
        },
        sms: %Schema{
          type: :array,
          description: """
          A list of phone sms phone numbers associated with the user.
          These numbers may be associated with third-party SMS services, such as Twilio,
          and can include mobile numbers capable of receiving text messages.
          """,
          items: %Schema{
            type: :string
          },
          example: ["380441234567", "+1-212-456-7890"]
        }
      },
      required: [:main]
    })
  end

  defmodule Contact do
    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        user_id: UserId,
        is_current_user: %Schema{
          type: :boolean,
          description: "Indicates whether the contact is associated with the same user who making the request.",
          example: false
        },
        sip_status: %Schema{
          type: :string,
          description: "The current registration status of the user on the SIP server.",
          enum: [
            :registered,
            :notregistered
          ]
        },
        numbers: Numbers,
        email: %Schema{
          type: :string,
          format: :email,
          description: "The user's email address.",
          example: "a.black@matrix.com"
        },
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
        alias_name: %Schema{
          type: :string,
          description: "The user's alternative name. May be used for indicate role or position.",
          example: "Receptionist"
        },
        company_name: %Schema{
          type: :string,
          description: "The name of the company the user is associated with.",
          example: "Matrix"
        }
      },
      required: [:numbers]
    })
  end

  defmodule VoicemailMessageId do
    OpenApiSpex.schema(%{
      type: :string,
      description: """
      A unique identifier for a voicemail message.
      """
    })
  end

  defmodule VoicemailMessage do
    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        id: VoicemailMessageId,
        type: %Schema{
          type: :string,
          description: "The type of the message.",
          enum: [
            :voice,
            :fax
          ]
        },
        duration: %Schema{
          type: :number,
          description: "The duration of the voice message in seconds.",
          example: 3.45
        },
        size: %Schema{
          type: :integer,
          description: "The total size of all attachments in the message in KB.",
          example: 5
        },
        date: %Schema{
          type: :string,
          format: "date-time",
          description: "The delivery date of the message."
        },
        seen: %Schema{
          type: :boolean,
          description: "Indicates whether this message has been seen.",
          example: false
        }
      },
      required: [:id, :type]
    })
  end

  defmodule VoicemailMessageAttachment do
    OpenApiSpex.schema(%{
      type: :object,
      properties: %{
        type: %Schema{
          type: :string,
          description: "The MIME type of the body.",
          example: "audio"
        },
        subtype: %Schema{
          type: :string,
          description: "The MIME subtype of the body.",
          example: "basic"
        },
        size: %Schema{
          type: :integer,
          description: "The size of the body in KB.",
          example: 5
        },
        filename: %Schema{
          type: :string,
          description: "The name of the attached file.",
          example: "voice_message_2024-06-07_12-32-03.au"
        }
      }
    })
  end

  defmodule VoicemailMessageAttachmentFileFormat do
    OpenApiSpex.schema(%{
      type: :string,
      description: "The file format of the message attachment."
    })
  end
end
