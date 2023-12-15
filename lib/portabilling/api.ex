defmodule Portabilling.Api do
  alias Portabilling.AccountSessionManager
  alias Portabilling.AdministratorSessionManager

  @json_library Phoenix.json_library()

  @spec client(URI.t() | String.t() | nil) :: Tesla.Client.t()
  def client(portabilling_url) do
    base_url = portabilling_url |> to_string()

    middleware = [
      {WebtritAdapter.Tesla.Middleware.RequestId, prefix: "PA/"},
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.FormUrlencoded,
      {Tesla.Middleware.DecodeJson, engine: @json_library},
      Tesla.Middleware.Logger
    ]

    Tesla.client(middleware)
  end

  def perform(client, {"Administrator", nil}, "Session" = service, method, params, return_headers) do
    request(client, service, method, params, nil, return_headers)
  end

  def perform(client, {"Administrator", nil}, service, method, params, return_headers) do
    session_id = AdministratorSessionManager.get_session_id()
    request(client, service, method, params, session_id, return_headers)
  end

  def perform(client, {"Account", nil}, "Session" = service, method, params, return_headers) do
    request(client, service, method, params, nil, return_headers)
  end

  def perform(client, {"Account", i_account}, service, method, params, return_headers) do
    case AccountSessionManager.get_session_id(i_account) do
      nil ->
        {:error, :missing_session_id}

      session_id ->
        request(client, service, method, params, session_id, return_headers)
    end
  end

  defp request(client, service, method, params, session_id, return_headers) do
    request_body =
      %{
        "params" => params,
        "auth_info" => %{
          "session_id" => session_id
        }
      }
      # remove key-value pairs with nil values
      |> Enum.filter(fn {_, v} -> v end)
      # encode values to JSON
      |> Enum.map(fn {k, v} -> {k, @json_library.encode!(v)} end)

    case Tesla.post(client, "/#{service}/#{method}/", request_body) do
      {:ok, %Tesla.Env{status: code, headers: response_headers, body: response_body}} ->
        if return_headers do
          {code, Enum.into(response_headers, %{}), response_body}
        else
          {code, response_body}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defmacro perform_contextual(client, unique_id \\ nil, params, return_headers \\ false) do
    [service, realm | _] =
      __CALLER__.module
      |> to_string()
      |> String.split(".")
      |> Enum.reverse()

    method =
      __CALLER__.function
      |> elem(0)
      |> to_string()

    quote do
      perform(
        unquote(client),
        unquote({realm, unique_id}),
        unquote(service),
        unquote(method),
        unquote(params),
        unquote(return_headers)
      )
    end
  end
end
