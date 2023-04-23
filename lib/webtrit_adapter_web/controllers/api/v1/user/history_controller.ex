defmodule WebtritAdapterWeb.Api.V1.User.HistoryController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs

  require OpenApiSpexExt

  alias Portabilling.Api
  alias OpenApiSpex.Schema
  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.CommonResponse
  alias WebtritAdapterWeb.Api.V1.User.HistorySchema

  plug OpenApiSpex.Plug.CastAndValidate, render_error: CastAndValidateRenderError

  action_fallback(FallbackController)

  tags(["user"])
  security([%{"bearerAuth" => []}])

  def action(%{assigns: %{i_account: i_account}} = conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, i_account])
  end

  OpenApiSpexExt.operation(:index,
    summary: "Retrieve the user's CDRs",
    description: """
    Retrieve the user's CDRs from the **Adaptee**.
    """,
    parameters: [
      page: [
        in: :query,
        schema: %Schema{type: :integer, minimum: 1, default: 1}
      ],
      items_per_page: [
        in: :query,
        schema: %Schema{type: :integer, minimum: 1, default: 100}
      ],
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
    case Api.Account.Account.get_xdr_list(
           conn.assigns.account_client,
           i_account,
           %{
             "limit" => params[:items_per_page],
             "offset" => (params[:page] - 1) * params[:items_per_page],
             "from_date" => strftime(params[:time_from]),
             "to_date" => strftime(params[:time_to])
           }
           |> Utils.Map.deep_filter_blank_values()
         ) do
      {200, %{"xdr_list" => xdr_list, "total" => total}} ->
        render(conn,
          xdr_list: xdr_list,
          page: params.page,
          items_per_page: params.items_per_page,
          items_total: total
        )

      {:error, :missing_session_id} ->
        {:error, :not_found, :session_not_found}

      _ ->
        {:error, :internal_server_error, :external_api_issue}
    end
  end

  defp strftime(nil), do: nil
  defp strftime(date_or_time_or_datetime), do: Calendar.strftime(date_or_time_or_datetime, "%c")
end
