defmodule WebtritAdapter.Plug.MetadataAcceptLanguageHeader do
  @behaviour Plug

  import Plug.Conn

  require Logger

  @impl true
  def init(args), do: args

  @impl true
  def call(conn, _) do
    accept_language = conn |> fetch_accept_language_header()

    Logger.metadata(accept_language: accept_language)

    conn
  end

  defp fetch_accept_language_header(conn) do
    conn |> get_req_header("accept-language") |> List.first()
  end
end
