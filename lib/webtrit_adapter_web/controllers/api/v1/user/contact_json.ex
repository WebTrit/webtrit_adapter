defmodule WebtritAdapterWeb.Api.V1.User.ContactJSON do
  alias WebtritAdapterWeb.Api.V1.User.Mapping

  def index(%{account_list: account_list}) do
    %{
      items: for(account <- account_list, do: data(account))
    }
  end

  defp data(account) do
    %{
      sip: %{
        display_name: Mapping.display_name(account),
        status: Mapping.sip_status(account)
      },
      numbers: %{
        main: account["id"],
        ext: account["extension_id"],
        additional: nil
      },
      first_name: account["firstname"],
      last_name: account["lastname"],
      email: account["email"],
      company_name: account["companyname"]
    }
    |> Utils.Map.deep_filter_blank_values()
  end
end
