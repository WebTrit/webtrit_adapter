defmodule WebtritAdapter.Plug.MetadataAcceptLanguageHeader do
  @behaviour Plug

  import Plug.Conn

  require Logger

  @impl true
  def init(args), do: args

  @impl true
  def call(conn, _) do
    if accept_language = fetch_accept_language_header(conn) do
      Logger.metadata(accept_language: accept_language)
    end

    conn
  end

  defp fetch_accept_language_header(conn) do
    case get_req_header(conn, "accept-language") do
      [] -> nil
      accept_language_headers -> Enum.join(accept_language_headers, ", ")
    end
  end
end
