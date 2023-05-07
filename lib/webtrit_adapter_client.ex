defmodule WebtritAdapterClient do
  @type result() :: {Tesla.Env.status(), Tesla.Env.body()} | {:error, any()}

  defmodule Middleware.BearerAuth do
    @behaviour Tesla.Middleware

    @impl Tesla.Middleware
    def call(env, next, opts \\ []) do
      access_token = Keyword.get(opts, :access_token)

      env
      |> put_header_auth_bearer(access_token)
      |> Tesla.run(next)
    end

    defp put_header_auth_bearer(env, nil), do: env

    defp put_header_auth_bearer(env, access_token) do
      Tesla.put_headers(env, [{"authorization", "Bearer #{access_token}"}])
    end
  end

  @spec new(URI.t() | String.t(), String.t() | nil) :: Tesla.Client.t()
  def new(adapter_url, access_token \\ nil) do
    base_url = URI.merge(URI.parse(adapter_url), "/api/v1") |> to_string()

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Middleware.BearerAuth, access_token: access_token},
      {Tesla.Middleware.JSON, engine: Phoenix.json_library()},
      Tesla.Middleware.Logger
    ]

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

  @spec create_session_otp(Tesla.Client.t(), String.t(), String.t() | nil) :: result()
  def create_session_otp(client, user_ref, tenant_id \\ nil) do
    options = [
      method: :post,
      url: "/session/otp-create",
      body: %{
        user_ref: user_ref
      }
    ]

    options = put_header_tenant_id(options, tenant_id)

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

  @spec create_session(Tesla.Client.t(), String.t(), String.t(), String.t() | nil) :: result()
  def create_session(client, login, password, tenant_id \\ nil) do
    options = [
      method: :post,
      url: "/session",
      body: %{
        login: login,
        password: password
      }
    ]

    options = put_header_tenant_id(options, tenant_id)

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

  @spec get_user_recording(Tesla.Client.t(), String.t()) :: result()
  def get_user_recording(client, recording_id) do
    options = [
      method: :get,
      url: "/user/recordings/#{recording_id}"
    ]

    request(client, options)
  end

  defp put_header_tenant_id(options, nil), do: options

  defp put_header_tenant_id(options, tenant_id) do
    options ++ [headers: [{"X-WebTrit-Tenant-ID", tenant_id}]]
  end

  defp request(client, options) do
    case Tesla.request(client, options) do
      {:ok, %Tesla.Env{status: code, body: body}} ->
        {code, body}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
