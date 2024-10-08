defmodule WebtritAdapterWeb.Api.V1.User.ContactJSON do
  alias WebtritAdapter.Mapper
  alias WebtritAdapterWeb.Api.V1.User.JSONMapping

  def index(%{account_list: account_list, current_user_i_account: current_user_i_account}) do
    %{
      items: for(account <- account_list, do: data(account, current_user_i_account))
    }
  end

  defp data(account, current_user_i_account) do
    %{
      user_id: Mapper.i_account_to_user_id(account["i_account"]),
      is_current_user: account["i_account"] == current_user_i_account,
      sip_status: JSONMapping.sip_status(account),
      numbers: %{
        main: account["id"],
        ext: account["extension_id"],
        additional: nil,
        sms: JSONMapping.alias_did_number_list_to_numbers(account["alias_did_number_list"])
      },
      first_name: account["firstname"],
      last_name: account["lastname"],
      alias_name: account["extension_name"],
      email: account["email"],
      company_name: account["companyname"]
    }
    |> Utils.Map.deep_filter_blank_values()
  end
end
