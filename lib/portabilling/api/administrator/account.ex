defmodule Portabilling.Api.Administrator.Account do
  import Portabilling.Api

  def get_account_list(client, %{} = params) do
    perform_contextual(
      client,
      Map.merge(
        %{
          "get_not_closed_accounts" => 1,
          "get_only_real_accounts" => 1,
          "limit" => 1000,
          "limit_alias_did_number_list" => 100
        },
        params
      )
    )
  end

  def get_account_info(client, %{} = params) do
    perform_contextual(
      client,
      Map.merge(
        %{
          "detailed_info" => 1,
          "without_service_features" => 1
        },
        params
      )
    )
  end

  def get_alias_list(client, %{} = params) do
    perform_contextual(client, params)
  end

  def update_account(client, %{} = params) do
    perform_contextual(client, params)
  end

  def update_custom_fields_values(client, %{} = params) do
    perform_contextual(client, params)
  end
end
