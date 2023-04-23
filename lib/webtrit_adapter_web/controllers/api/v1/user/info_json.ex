defmodule WebtritAdapterWeb.Api.V1.User.InfoJSON do
  import Config.Portasip
  import Config.Janussip

  alias WebtritAdapterWeb.Api.V1.User.Mapping

  def show(%{account_info: account_info, alias_list: alias_list}) do
    %{
      sip: %{
        login: account_info["id"],
        password: account_info["h323_password"],
        sip_server: %{
          host: host(),
          port: port(),
          force_tcp: force_tcp()
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
      first_name: account_info["firstname"],
      last_name: account_info["lastname"],
      email: account_info["email"],
      company_name: account_info["companyname"],
      time_zone: account_info["time_zone_name"]
    }
    |> Utils.Map.deep_filter_blank_values()
  end
end
