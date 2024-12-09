defmodule Portabilling.Api.Administrator.Customer do
  import Portabilling.Api

  def get_customer_list(client, %{} = params) do
    perform_contextual(
      client,
      Map.merge(
        %{
          "limit" => 1000
        },
        params
      )
    )
  end
end
