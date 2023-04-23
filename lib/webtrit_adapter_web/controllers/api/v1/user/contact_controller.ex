defmodule WebtritAdapterWeb.Api.V1.User.ContactController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs

  require OpenApiSpexExt

  alias Portabilling.Api
  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.CommonResponse
  alias WebtritAdapterWeb.Api.V1.User.ContactSchema

  plug(OpenApiSpex.Plug.CastAndValidate, render_error: CastAndValidateRenderError)

  action_fallback(FallbackController)

  tags(["user"])
  security([%{"bearerAuth" => []}])

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
            ip_centrex_account_list = Enum.filter(account_list, fn account -> account["extension_id"] end)

            render(conn, account_list: ip_centrex_account_list)

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
