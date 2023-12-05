defmodule WebtritAdapter.Plug.MetadataXHeaders do
  @behaviour Plug

  require Logger

  @impl true
  def init(args), do: args

  @impl true
  def call(conn, _) do
    x_headers = fetch_x_headers(conn)

    Logger.metadata(x_headers: x_headers)

    conn
  end

  defp fetch_x_headers(conn) do
    for {header, _} = pair <- conn.req_headers,
        String.starts_with?(header, ["x-", "X-"]) and String.downcase(header) != "x-request-id",
        do: pair
  end
end
