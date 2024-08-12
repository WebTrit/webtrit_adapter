defmodule WebtritAdapterWeb.Api.V1.User.InfoController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs
  use OpenApiSpexExt

  alias Portabilling.Api
  alias WebtritAdapter.Session
  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.CommonResponse
  alias WebtritAdapterWeb.Api.V1.User.InfoSchema
  alias WebtritAdapterWeb.Api.V1.User.ControllerMapping

  plug OpenApiSpex.Plug.CastAndValidate, render_error: CastAndValidateRenderError

  action_fallback FallbackController

  tags ["user"]
  security [%{"bearerAuth" => []}]
  OpenApiSpexExt.parameters("$ref": "#/components/parameters/TenantID")
  OpenApiSpexExt.parameters("$ref": "#/components/parameters/AcceptLanguage")

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
      CommonResponse.forbidden(),
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
            hide_balance = WebtritAdapterConfig.portabilling_hide_balance_in_user_info?()

            render(conn, account_info: account_info, alias_list: alias_list, hide_balance?: hide_balance)

          {:error, error} ->
            ControllerMapping.api_account_error_to_action_error(error)

          _ ->
            {:error, :internal_server_error, :external_api_issue}
        end

      {200, %{}} ->
        {:error, :not_found, :user_not_found}

      {:error, error} ->
        ControllerMapping.api_account_error_to_action_error(error)

      _ ->
        {:error, :internal_server_error, :external_api_issue}
    end
  end

  OpenApiSpexExt.operation(:delete,
    summary: "Delete user",
    description: """
    Delete the user and user's data with associated information included sessions.
    """,
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.session_and_user_not_found(),
      CommonResponse.external_api_issue(),
      no_content: "Deleted successfully."
    ]
  )

  def delete(conn, _params, i_account) do
    # TODO: delete/deactivate account with Portabilling.Api

    {_, nil} = Session.delete_all_refresh_token(i_account)

    send_resp(conn, :no_content, "")
  end
end
