defmodule Portabilling.Api.Account.Session do
  import Portabilling.Api

  def login(client, %{} = params) do
    perform_contextual(client, params)
  end

  def logout(client, %{} = params) do
    perform_contextual(client, params)
  end

  def change_password(client, %{} = params) do
    perform_contextual(client, params)
  end
end
