defmodule WebtritAdapterClient do
  @type result() :: {Tesla.Env.status(), Tesla.Env.body()} | {:error, any()}
  @type headers_map() :: map()
  @type result_with_headers() :: {Tesla.Env.status(), headers_map(), Tesla.Env.body()} | {:error, any()}

  @spec new(URI.t() | String.t(), String.t() | nil, String.t() | nil) :: Tesla.Client.t()
  def new(adapter_url, tenant_id \\ nil, access_token \\ nil) do
    base_url = URI.merge(URI.parse(adapter_url), "." <> "/api/v1") |> to_string()

    middleware =
      []
      |> then(&[Tesla.Middleware.Logger | &1])
      |> then(&[{Tesla.Middleware.JSON, engine: Phoenix.json_library()} | &1])
      |> then(fn
        m when is_nil(tenant_id) -> m
        m -> [{Tesla.Middleware.Headers, [{"X-WebTrit-Tenant-ID", tenant_id}]} | m]
      end)
      |> then(fn
        m when is_nil(access_token) -> m
        m -> [{Tesla.Middleware.BearerAuth, token: access_token} | m]
      end)
      |> then(&[{Tesla.Middleware.BaseUrl, base_url} | &1])
      |> then(&[{WebtritAdapter.Tesla.Middleware.RequestId, prefix: "WAC/"} | &1])
      |> then(&[WebtritAdapter.Tesla.Middleware.MetadataXHeaders | &1])

    Tesla.client(middleware)
  end

  @spec get_system_info(Tesla.Client.t()) :: result()
  def get_system_info(client) do
    options = [
      method: :get,
      url: "/system-info"
    ]

    request(client, options)
  end

  @spec create_session_otp(Tesla.Client.t(), String.t()) :: result()
  def create_session_otp(client, user_ref) do
    options = [
      method: :post,
      url: "/session/otp-create",
      body: %{
        user_ref: user_ref
      }
    ]

    request(client, options)
  end

  @spec verify_session_otp(Tesla.Client.t(), String.t(), String.t()) :: result()
  def verify_session_otp(client, otp_id, code) do
    options = [
      method: :post,
      url: "/session/otp-verify",
      body: %{
        otp_id: otp_id,
        code: code
      }
    ]

    request(client, options)
  end

  @spec create_session(Tesla.Client.t(), String.t(), String.t()) :: result()
  def create_session(client, login, password) do
    options = [
      method: :post,
      url: "/session",
      body: %{
        login: login,
        password: password
      }
    ]

    request(client, options)
  end

  @spec auto_provision_session(Tesla.Client.t(), String.t()) :: result()
  def auto_provision_session(client, config_token) do
    options = [
      method: :post,
      url: "/session/auto-provision",
      body: %{
        config_token: config_token
      }
    ]

    request(client, options)
  end

  @spec update_session(Tesla.Client.t(), String.t()) :: result()
  def update_session(client, refresh_token) do
    options = [
      method: :patch,
      url: "/session",
      body: %{
        refresh_token: refresh_token
      }
    ]

    request(client, options)
  end

  @spec delete_session(Tesla.Client.t()) :: result()
  def delete_session(client) do
    options = [
      method: :delete,
      url: "/session"
    ]

    request(client, options)
  end

  @spec create_user(Tesla.Client.t(), map()) :: result()
  def create_user(client, data) do
    options = [
      method: :post,
      url: "/user",
      body: data
    ]

    request(client, options)
  end

  @spec get_user_info(Tesla.Client.t()) :: result()
  def get_user_info(client) do
    options = [
      method: :get,
      url: "/user"
    ]

    request(client, options)
  end

  @spec delete_user(Tesla.Client.t()) :: result()
  def delete_user(client) do
    options = [
      method: :delete,
      url: "/user"
    ]

    request(client, options)
  end

  @spec get_user_contact_list(Tesla.Client.t()) :: result()
  def get_user_contact_list(client) do
    options = [
      method: :get,
      url: "/user/contacts"
    ]

    request(client, options)
  end

  @spec get_user_history_list(Tesla.Client.t(), Tesla.Env.query() | nil) :: result()
  def get_user_history_list(client, query \\ []) do
    options = [
      method: :get,
      url: "/user/history",
      query: query
    ]

    request(client, options)
  end

  @spec get_user_recording(Tesla.Client.t(), String.t()) :: result_with_headers()
  def get_user_recording(client, recording_id) do
    options = [
      method: :get,
      url: "/user/recordings/#{recording_id}"
    ]

    request(client, options, true)
  end

  defp request(client, options, return_headers \\ false) do
    case Tesla.request(client, options) do
      {:ok, %Tesla.Env{status: code, headers: headers, body: body}} ->
        if return_headers do
          {code, Enum.into(headers, %{}), body}
        else
          {code, body}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
