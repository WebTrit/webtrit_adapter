defmodule WebtritAdapterWeb.Api.V1.User.InfoJSON do
  alias WebtritAdapterWeb.Api.V1.User.JSONMapping

  def show(%{account_info: account_info, alias_list: alias_list, hide_balance?: hide_balance}) do
    info_without_balance =
      %{
        status: JSONMapping.status(account_info),
        sip: %{
          username: account_info["id"],
          password: account_info["h323_password"],
          transport: sip_transport(),
          sip_server: %{
            host: WebtritAdapterConfig.portasip_host(),
            port: WebtritAdapterConfig.portasip_port()
          },
          registrar_server: nil,
          outbound_proxy_server: nil,
          display_name: JSONMapping.display_name(account_info)
        },
        numbers: %{
          main: account_info["id"],
          ext: account_info["extension_id"],
          additional: JSONMapping.alias_list_to_numbers(alias_list),
          sms: JSONMapping.alias_did_number_list_to_numbers(account_info["alias_did_number_list"])
        },
        email: account_info["email"],
        first_name: account_info["firstname"],
        last_name: account_info["lastname"],
        alias_name: account_info["extension_name"],
        company_name: account_info["companyname"],
        time_zone: account_info["time_zone_name"]
      }
      |> Utils.Map.deep_filter_blank_values()

    case hide_balance do
      true ->
        info_without_balance

      false ->
        balance =
          %{
            balance_type: JSONMapping.balance_type(account_info),
            amount: account_info["balance"],
            credit_limit: account_info["credit_limit"],
            currency: account_info["iso_4217"] || "$"
          }
          |> Utils.Map.deep_filter_blank_values()

        Map.put(info_without_balance, :balance, balance)
    end
  end

  defp sip_transport(), do: if(WebtritAdapterConfig.janus_sip_force_tcp(), do: :TCP, else: :UDP)
end
