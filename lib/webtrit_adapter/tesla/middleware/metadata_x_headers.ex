defmodule WebtritAdapter.Tesla.Middleware.MetadataXHeaders do
  @behaviour Tesla.Middleware

  require Logger

  @impl true
  def call(env, next, _opts) do
    x_headers = Logger.metadata()[:x_headers] || []

    env
    |> Tesla.put_headers(x_headers)
    |> Tesla.run(next)
  end
end
