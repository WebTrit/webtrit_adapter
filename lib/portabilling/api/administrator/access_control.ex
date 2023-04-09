defmodule Portabilling.Api.Administrator.AccessControl do
  import Portabilling.Api

  def create_otp(client, %{} = params) do
    perform_contextual(
      client,
      Map.merge(
        %{
          "notification_type" => "mail",
          "send_to" => "account"
        },
        params
      )
    )
  end

  def verify_otp(client, %{} = params) do
    perform_contextual(client, params)
  end
end
