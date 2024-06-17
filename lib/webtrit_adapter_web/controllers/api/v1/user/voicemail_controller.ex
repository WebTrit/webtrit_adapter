defmodule WebtritAdapterWeb.Api.V1.User.VoicemailController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs

  require OpenApiSpexExt

  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.CommonResponse
  alias WebtritAdapterWeb.Api.V1.CommonSchema
  alias WebtritAdapterWeb.Api.V1.User.VoicemailSchema

  plug OpenApiSpex.Plug.CastAndValidate, render_error: CastAndValidateRenderError

  action_fallback FallbackController

  tags ["user"]
  security [%{"bearerAuth" => []}]
  OpenApiSpexExt.parameters("$ref": "#/components/parameters/AcceptLanguage")

  def action(%{assigns: %{i_account: i_account}} = conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, i_account])
  end

  OpenApiSpexExt.operation(:index,
    summary: "Retrieve the user's voicemails",
    description: """
    Retrieve the user's voicemail messages from the **Adaptee**.
    """,
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.forbidden(),
      CommonResponse.not_found([
        :session_not_found,
        :user_not_found
      ]),
      CommonResponse.unprocessable(),
      CommonResponse.external_api_issue(),
      CommonResponse.functionality_not_implemented(),
      ok: {
        "Ok",
        "application/json",
        VoicemailSchema.IndexResponse
      }
    ]
  )

  def index(_conn, _params, _i_account) do
    {:error, :not_implemented, :functionality_not_implemented}
  end

  OpenApiSpexExt.operation(:show,
    summary: "Retrieve a message details",
    description: """
    Retrieve the user's voicemail message details from the **Adaptee**.
    """,
    parameters: [
      message_id: [
        in: :path,
        schema: CommonSchema.VoicemailMessageId
      ]
    ],
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.forbidden(),
      CommonResponse.not_found([
        :session_not_found,
        :user_not_found,
        :message_not_found
      ]),
      CommonResponse.unprocessable(),
      CommonResponse.external_api_issue(),
      CommonResponse.functionality_not_implemented(),
      ok: {
        "Ok",
        "application/json",
        VoicemailSchema.ShowResponse
      }
    ]
  )

  def show(_conn, _params, _i_account) do
    {:error, :not_implemented, :functionality_not_implemented}
  end

  OpenApiSpexExt.operation(:update,
    summary: "Patch voicemail message",
    description: """
    Patch the user's voicemail message in the **Adaptee**.
    """,
    parameters: [
      message_id: [
        in: :path,
        schema: CommonSchema.VoicemailMessageId
      ]
    ],
    request_body: {
      "Update information.",
      "application/json",
      VoicemailSchema.Patch,
      required: true
    },
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.forbidden(),
      CommonResponse.not_found([
        :session_not_found,
        :user_not_found,
        :message_not_found
      ]),
      CommonResponse.unprocessable(),
      CommonResponse.external_api_issue(),
      CommonResponse.functionality_not_implemented(),
      ok: {
        "Ok",
        "application/json",
        VoicemailSchema.Patch
      }
    ]
  )

  def update(_conn, _params, _i_account) do
    {:error, :not_implemented, :functionality_not_implemented}
  end

  OpenApiSpexExt.operation(:delete,
    summary: "Delete voicemail message",
    description: """
    Delete the user's voicemail message in the **Adaptee**.
    """,
    parameters: [
      message_id: [
        in: :path,
        schema: CommonSchema.VoicemailMessageId
      ]
    ],
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.forbidden(),
      CommonResponse.not_found([
        :session_not_found,
        :user_not_found,
        :message_not_found
      ]),
      CommonResponse.unprocessable(),
      CommonResponse.external_api_issue(),
      CommonResponse.functionality_not_implemented(),
      no_content: "Ok"
    ]
  )

  def delete(_conn, _params, _i_account) do
    {:error, :not_implemented, :functionality_not_implemented}
  end

  OpenApiSpexExt.operation(:show_attachment,
    summary: "Retrieve a message attachment",
    description: """
    Retrieve and download media data containing a attachment of a voicemail message
    from the **Adaptee**.
    """,
    parameters: [
      message_id: [
        in: :path,
        schema: CommonSchema.VoicemailMessageId
      ],
      file_format: [
        in: :query,
        schema: CommonSchema.VoicemailMessageAttachmentFileFormat
      ]
    ],
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.forbidden(),
      CommonResponse.not_found([
        :session_not_found,
        :user_not_found,
        :message_not_found
      ]),
      CommonResponse.unprocessable([
        :unsupported_file_format
      ]),
      CommonResponse.external_api_issue(),
      CommonResponse.functionality_not_implemented(),
      ok: {
        "Ok",
        "application/json",
        CommonSchema.BinaryResponse
      },
      method_not_allowed: {
        """
        Method not allowed, with next possible codes:
        * `#{:user_session_issue}`
        """,
        "application/json",
        CommonSchema.ErrorResponse
      }
    ]
  )

  def show_attachment(_conn, _params, _i_account) do
    {:error, :not_implemented, :functionality_not_implemented}
  end
end
