defmodule WebtritAdapterWeb.Api.V1.User.RecordingController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs
  use OpenApiSpexExt

  alias Portabilling.Api
  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.CommonResponse
  alias WebtritAdapterWeb.Api.V1.CommonSchema

  plug OpenApiSpex.Plug.CastAndValidate, render_error: CastAndValidateRenderError

  action_fallback FallbackController

  tags ["user"]
  security [%{"bearerAuth" => []}]
  OpenApiSpexExt.parameters("$ref": "#/components/parameters/TenantID")

  def action(%{assigns: %{i_account: i_account}} = conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, i_account])
  end

  OpenApiSpexExt.operation(:show,
    summary: "Retrieve a call recording",
    description: """
    Retrieve and download media data containing a recording of a call
    from the **Adaptee**.
    """,
    parameters: [
      recording_id: [
        in: :path,
        schema: CommonSchema.CallRecordingId
      ]
    ],
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.session_and_user_not_found(),
      CommonResponse.unprocessable(),
      CommonResponse.external_api_issue(),
      ok: {
        """
        Media data containing the call recording.
        """,
        %{
          "audio/mpeg" => [],
          "application/zip" => []
        },
        CommonSchema.BinaryResponse
      }
    ]
  )

  def show(conn, %{recording_id: i_xdr}, i_account) do
    case Api.Account.CDR.get_call_recording(
           conn.assigns.account_client,
           i_account,
           %{i_xdr: i_xdr}
         ) do
      {200, content_type, data} ->
        send_download(conn, {:binary, data}, filename: "#{i_xdr}", disposition: :inline, content_type: content_type)

      {:error, :missing_session_id} ->
        {:error, :not_found, :session_not_found}

      _ ->
        {:error, :internal_server_error, :external_api_issue}
    end
  end
end
