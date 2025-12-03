defmodule WebtritAdapterWeb.Api.V1.User.ContactController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs
  use OpenApiSpexExt

  alias Portabilling.Api
  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.{CommonResponse, CommonSchema}
  alias WebtritAdapterWeb.Api.V1.User.ContactSchema
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
      {200, %{"account_info" => %{"i_customer" => i_customer, "customer_name" => customer_name}}} ->
        case Api.Administrator.Customer.get_customer_list(
               conn.assigns.administrator_client,
               %{name: customer_name}
             ) do
          {200, %{"customer_list" => customer_list}} ->
            customer_dual_version_system =
              customer_list
              |> Enum.find(fn customer -> customer["bill_status"] == "O" end)
              |> Map.get("dual_version_system")

            case Api.Administrator.Account.get_account_list(
                   conn.assigns.administrator_client,
                   %{i_customer: i_customer}
                 ) do
              {200, %{"account_list" => account_list}} ->
                ip_centrex_account_list =
                  Enum.filter(account_list, fn account ->
                    account_status = Map.get(account, "status")

                    cond do
                      account_status == "blocked" ->
                        false

                      account["dual_version_system"] in [nil, customer_dual_version_system] ->
                        !WebtritAdapterConfig.portabilling_filter_contacts_without_extension() or
                          account["extension_id"] != nil

                      true ->
                        false
                    end
                  end)

                render(conn, account_list: ip_centrex_account_list, current_user_i_account: i_account)

              _ ->
                {:error, :internal_server_error, :external_api_issue}
            end

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

  OpenApiSpexExt.operation(:show,
    summary: "Retrieve a contact by UserId",
    description: """
    Retrieve extension number and name of a specific user
    within the same **Adaptee** by their UserId.
    """,
    parameters: [
      user_id: [
        in: :path,
        description: "The unique identifier of the user",
        schema: CommonSchema.UserId
      ]
    ],
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.forbidden(),
      CommonResponse.not_found([
        :session_not_found,
        :user_not_found,
        :contact_not_found
      ]),
      CommonResponse.unprocessable(),
      CommonResponse.external_api_issue(),
      CommonResponse.functionality_not_implemented(),
      ok: {
        "Ok",
        "application/json",
        CommonSchema.Contact
      }
    ]
  )

  def show(_conn, _params, _user_id) do
    {:error, :not_implemented, :functionality_not_implemented}
  end
end
