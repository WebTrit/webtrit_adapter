defmodule WebtritAdapterWeb.Api.V1.User.InfoController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs
  use OpenApiSpexExt

  alias Portabilling.Api
  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.CommonResponse
  alias WebtritAdapterWeb.Api.V1.User.InfoSchema

  plug OpenApiSpex.Plug.CastAndValidate, render_error: CastAndValidateRenderError

  action_fallback FallbackController

  tags ["user"]
  security [%{"bearerAuth" => []}]
  OpenApiSpexExt.parameters("$ref": "#/components/parameters/TenantID")

  def action(%{assigns: %{i_account: i_account}} = conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, i_account])
  end

  OpenApiSpexExt.operation(:show,
    summary: "Retrieve user information",
    description: """
    Fetch the user's data, such as the SIP server address, SIP username,
    and password, required for registration to the remote VoIP system
    and placing calls through it.
    """,
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.session_and_user_not_found(),
      CommonResponse.unprocessable(),
      CommonResponse.external_api_issue(),
      ok: {
        """
        User information and related data.
        """,
        "application/json",
        InfoSchema.ShowResponse
      }
    ]
  )

  def show(conn, _params, i_account) do
    case Api.Account.Account.get_account_info(
           conn.assigns.account_client,
           i_account,
           %{i_account: i_account}
         ) do
      {200, %{"account_info" => account_info}} ->
        case Api.Account.Account.get_alias_list(
               conn.assigns.account_client,
               i_account,
               %{
                 i_master_account: i_account
               }
             ) do
          {200, %{"alias_list" => alias_list}} ->
            render(conn, account_info: account_info, alias_list: alias_list)

          {:error, :missing_session_id} ->
            {:error, :not_found, :session_not_found}

          _ ->
            {:error, :internal_server_error, :external_api_issue}
        end

      {200, %{}} ->
        {:error, :not_found, :user_not_found}

      {:error, :missing_session_id} ->
        {:error, :not_found, :session_not_found}

      _ ->
        {:error, :internal_server_error, :external_api_issue}
    end
  end
end
