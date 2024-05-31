defmodule WebtritAdapterWeb.Api.V1.User.ContactController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs
  use OpenApiSpexExt

  alias Portabilling.Api
  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.CommonResponse
  alias WebtritAdapterWeb.Api.V1.User.ContactSchema
  alias WebtritAdapterWeb.Api.V1.User.ControllerMapping

  plug OpenApiSpex.Plug.CastAndValidate, render_error: CastAndValidateRenderError

  action_fallback FallbackController

  tags ["user"]
  security [%{"bearerAuth" => []}]
  OpenApiSpexExt.parameters("$ref": "#/components/parameters/TenantID")

  def action(%{assigns: %{i_account: i_account}} = conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, i_account])
  end

  OpenApiSpexExt.operation(:index,
    summary: "Retrieve corporate phone directory (other extensions in the same Adaptee)",
    description: """
    Retrieve extension numbers and names of other users
    within the same **Adaptee**, allowing the user to view and dial their colleagues.
    """,
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.forbidden(),
      CommonResponse.session_and_user_not_found(),
      CommonResponse.unprocessable(),
      CommonResponse.external_api_issue(),
      ok: {
        """
        List of other users (extensions) within the **Adaptee**.
        """,
        "application/json",
        ContactSchema.IndexResponse
      }
    ]
  )

  def index(conn, _params, i_account) do
    case Api.Account.Account.get_account_info(
           conn.assigns.account_client,
           i_account,
           %{i_account: i_account}
         ) do
      {200, %{"account_info" => %{"i_customer" => i_customer}}} ->
        case Api.Administrator.Account.get_account_list(
               conn.assigns.administrator_client,
               %{i_customer: i_customer}
             ) do
          {200, %{"account_list" => account_list}} ->
            ip_centrex_account_list =
              Enum.filter(account_list, fn account ->
                account["extension_id"] != nil or account["dual_version_system"] in [nil, "target"]
              end)

            render(conn, account_list: ip_centrex_account_list, current_user_i_account: i_account)

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
end
