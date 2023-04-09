defmodule Portabilling.Api.Account.Account do
  import Portabilling.Api

  def get_xdr_list(client, i_account, %{} = params) do
    perform_contextual(
      client,
      i_account,
      Map.merge(
        %{
          "to_date" => "9999-01-01 00:00:00",
          "from_date" => "0001-01-01 00:00:00",
          "get_total" => 1,
          "i_service_type" => 3,
          "limit" => 100,
          "offset" => 0,
          "show_unsuccessful" => 1
        },
        params
      )
    )
  end

  def get_account_info(client, session_id, %{} = params) do
    perform_contextual(
      client,
      session_id,
      Map.merge(
        %{
          "detailed_info" => 1,
          "without_service_features" => 1
        },
        params
      )
    )
  end

  def get_alias_list(client, session_id, %{} = params) do
    perform_contextual(client, session_id, params)
  end
end
