defmodule WebtritAdapter.Tesla.Middleware.CustomHeaders do
  @behaviour Tesla.Middleware

  require Logger

  @impl true
  def call(env, next, _opts) do
    custom_headers = Logger.metadata()[:custom_headers]

    env
    |> Tesla.put_headers(custom_headers)
    |> Tesla.run(next)
  end
end
