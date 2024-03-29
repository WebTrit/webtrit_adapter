defmodule WebtritAdapterWeb.Api.V1.User.ContactJSON do
  alias WebtritAdapterWeb.Api.V1.User.JSONMapping

  def index(%{account_list: account_list}) do
    %{
      items: for(account <- account_list, do: data(account))
    }
  end

  defp data(account) do
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
      company_name: account["companyname"]
    }
    |> Utils.Map.deep_filter_blank_values()
  end
end
