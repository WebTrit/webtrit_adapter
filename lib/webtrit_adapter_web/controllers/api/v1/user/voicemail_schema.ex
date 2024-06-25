defmodule WebtritAdapterWeb.Api.V1.User.VoicemailSchema do
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
          items: CommonSchema.VoicemailMessage
        },
        has_new_messages: %Schema{
          type: :boolean
        }
      }
    })
  end

  defmodule ShowResponse do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        id: CommonSchema.VoicemailMessageId,
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
        },
        sender: CommonSchema.UserRef,
        receiver: CommonSchema.UserRef,
        attachments: %Schema{
          type: :array,
          items: CommonSchema.VoicemailMessageAttachment
        }
      }
    })
  end

  defmodule Patch do
    OpenApiSpexExt.schema(%{
      type: :object,
      properties: %{
        seen: %Schema{
          type: :boolean,
          description: "Marks the voicemail message as seen if it is `True`, unmarks otherwise.",
          example: true
        }
      }
    })
  end
end
