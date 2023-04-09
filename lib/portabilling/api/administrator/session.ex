defmodule Portabilling.Api.Administrator.Session do
  import Portabilling.Api

  def login(client, %{} = params) do
    perform_contextual(client, params)
  end

  def logout(client, %{} = params) do
    perform_contextual(client, params)
  end
end
