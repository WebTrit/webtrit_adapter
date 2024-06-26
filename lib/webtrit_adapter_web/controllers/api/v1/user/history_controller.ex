defmodule WebtritAdapterWeb.Api.V1.User.HistoryController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs
  use OpenApiSpexExt

  alias Portabilling.Api
  alias OpenApiSpex.Schema
  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.CommonParameter
  alias WebtritAdapterWeb.Api.V1.CommonResponse
  alias WebtritAdapterWeb.Api.V1.User.HistorySchema
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
    summary: "Retrieve the user's CDRs",
    description: """
    Retrieve the user's CDRs from the **Adaptee**.
    """,
    parameters: [
      CommonParameter.page(),
      CommonParameter.items_per_page(),
      time_from: [
        in: :query,
        description: "Filter CDRs by start time (inclusive)",
        schema: %Schema{type: :string, format: :"date-time"}
      ],
      time_to: [
        in: :query,
        description: "Filter CDRs by end time (exclusive)",
        schema: %Schema{type: :string, format: :"date-time"}
      ]
    ],
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.forbidden(),
      CommonResponse.session_and_user_not_found(),
      CommonResponse.unprocessable(),
      CommonResponse.external_api_issue(),
      ok: {
        "List of CDRs.",
        "application/json",
        HistorySchema.IndexResponse
      }
    ]
  )

  def index(conn, params, i_account) do
    time_zone = "Etc/UTC"

    case Api.Account.Account.get_xdr_list(
           conn.assigns.account_client,
           i_account,
           %{
             "limit" => params[:items_per_page],
             "offset" => (params[:page] - 1) * params[:items_per_page],
             "from_date" => to_portabilling_date_string!(params[:time_from], time_zone),
             "to_date" => to_portabilling_date_string!(params[:time_to], time_zone)
           }
           |> Utils.Map.deep_filter_blank_values()
         ) do
      {200, %{"xdr_list" => xdr_list, "total" => total}} ->
        render(conn,
          xdr_list: xdr_list,
          time_zone: time_zone,
          page: params.page,
          items_per_page: params.items_per_page,
          items_total: total
        )

      {:error, error} ->
        ControllerMapping.api_account_error_to_action_error(error)

      _ ->
        {:error, :internal_server_error, :external_api_issue}
    end
  end

  defp to_portabilling_date_string!(nil, _) do
    nil
  end

  defp to_portabilling_date_string!(datetime, time_zone) do
    datetime
    |> DateTime.shift_zone!(time_zone)
    |> DateTime.to_naive()
    # PortaBilling can only process date parameters only with seconds precision
    |> NaiveDateTime.truncate(:second)
    |> NaiveDateTime.to_string()
  end
end
