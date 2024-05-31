defmodule WebtritAdapterWeb.Api.V1.User.ContactJSON do
  alias WebtritAdapterWeb.Api.V1.User.JSONMapping

  def index(%{account_list: account_list, current_user_i_account: current_user_i_account}) do
    %{
      items: for(account <- account_list, do: data(account, current_user_i_account))
    }
  end

  defp data(account, current_user_i_account) do
    %{
      sip_status: JSONMapping.sip_status(account),
      numbers: %{
        main: account["id"],
        ext: account["extension_id"],
        additional: nil
      },
      first_name: account["firstname"],
      last_name: account["lastname"],
      alias_name: account["extension_name"],
      email: account["email"],
      company_name: account["companyname"],
      is_current_user: account["i_account"] == current_user_i_account
    }
    |> Utils.Map.deep_filter_blank_values()
  end
end
