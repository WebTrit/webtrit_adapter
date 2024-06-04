defmodule WebtritAdapter.Tesla.Middleware.AcceptLanguage do
  @behaviour Tesla.Middleware

  require Logger

  @impl true
  def call(env, next, opts) do
    accept_language = Logger.metadata()[:accept_language]
    accept_language_header = Keyword.get(opts, :http_header, "Accept-Language")

    env
    |> maybe_put_header(accept_language_header, accept_language)
    |> Tesla.run(next)
  end

  defp maybe_put_header(env, _header, nil), do: env
  defp maybe_put_header(env, header, value), do: Tesla.put_header(env, header, value)
end
