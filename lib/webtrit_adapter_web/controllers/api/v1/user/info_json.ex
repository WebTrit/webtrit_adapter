defmodule WebtritAdapterWeb.Api.V1.User.InfoJSON do
  alias WebtritAdapterWeb.Api.V1.User.Mapping

  def show(%{account_info: account_info, alias_list: alias_list}) do
    %{
      status: Mapping.status(account_info),
      sip: %{
        login: account_info["id"],
        password: account_info["h323_password"],
        sip_server: %{
          host: WebtritAdapterConfig.portasip_host(),
          port: WebtritAdapterConfig.portasip_port(),
          force_tcp: WebtritAdapterConfig.janus_sip_force_tcp()
        },
        registration_server: nil,
        display_name: Mapping.display_name(account_info)
      },
      balance: %{
        balance_type: Mapping.balance_type(account_info),
        amount: account_info["balance"],
        credit_limit: account_info["credit_limit"],
        currency: account_info["iso_4217"] || "$"
      },
      numbers: %{
        main: account_info["id"],
        ext: account_info["extension_id"],
        additional: Mapping.alias_list_to_numbers(alias_list)
      },
      email: account_info["email"],
      first_name: account_info["firstname"],
      last_name: account_info["lastname"],
      alias_name: account_info["extension_name"],
      company_name: account_info["companyname"],
      time_zone: account_info["time_zone_name"]
    }
    |> Utils.Map.deep_filter_blank_values()
  end
end
