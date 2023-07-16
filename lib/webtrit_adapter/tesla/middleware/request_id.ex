defmodule WebtritAdapter.Tesla.Middleware.RequestId do
  @behaviour Tesla.Middleware

  require Logger

  @impl true
  def call(env, next, opts) do
    request_id_http_header = Keyword.get(opts, :http_header, "x-request-id")

    request_id = Logger.metadata()[:request_id] || generate_request_id(opts)

    env
    |> Tesla.put_header(request_id_http_header, request_id)
    |> Tesla.run(next)
  end

  defp generate_request_id(opts) do
    request_id_prefix = Keyword.get(opts, :prefix, "")

    # Inspired by Plug.RequestId
    binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::32
    >>

    request_id_prefix <> Base.url_encode64(binary)
  end
end
