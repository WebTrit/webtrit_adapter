defmodule WebtritAdapterWeb.Api.V1.Plug.AssignPortabillingApiClients do
  import Plug.Conn
  import Config.Portabilling

  alias Portabilling.Api

  def init(default), do: default

  def call(conn, _default) do
    conn
    |> assign(:administrator_client, Api.client(administrator_url()))
    |> assign(:account_client, Api.client(account_url()))
  end
end
