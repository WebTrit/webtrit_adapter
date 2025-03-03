defmodule WebtritAdapterClient do
  @type content_type() :: binary()
  @type result() ::
          {Tesla.Env.status(), Tesla.Env.body()}
          | {Tesla.Env.status(), content_type(), Tesla.Env.body()}
          | {:error, any()}

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
      |> then(&[WebtritAdapter.Tesla.Middleware.AcceptLanguage | &1])

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
  def create_session(client, user_ref, password) do
    options = [
      method: :post,
      url: "/session",
      body: %{
        user_ref: user_ref,
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

  @spec get_user_recording(Tesla.Client.t(), String.t()) :: result()
  def get_user_recording(client, recording_id) do
    options = [
      method: :get,
      url: "/user/recordings/#{recording_id}"
    ]

    request(client, options)
  end

  @spec get_user_voicemail_messages(Tesla.Client.t()) :: result()
  def get_user_voicemail_messages(client) do
    options = [
      method: :get,
      url: "/user/voicemails"
    ]

    request(client, options)
  end

  @spec get_user_voicemail_message_details(Tesla.Client.t(), String.t()) :: result()
  def get_user_voicemail_message_details(client, message_id) do
    options = [
      method: :get,
      url: "/user/voicemails/#{message_id}"
    ]

    request(client, options)
  end

  @spec get_user_voicemail_message_attachment(Tesla.Client.t(), String.t(), Tesla.Env.query() | nil) :: result()
  def get_user_voicemail_message_attachment(client, message_id, query \\ []) do
    options = [
      method: :get,
      url: "/user/voicemails/#{message_id}/attachment",
      query: query
    ]

    request(client, options)
  end

  @spec patch_user_voicemail_message(Tesla.Client.t(), String.t(), map()) :: result()
  def patch_user_voicemail_message(client, message_id, data) do
    options = [
      method: :patch,
      url: "/user/voicemails/#{message_id}",
      body: data
    ]

    request(client, options)
  end

  @spec delete_user_voicemail_message(Tesla.Client.t(), String.t()) :: result()
  def delete_user_voicemail_message(client, message_id) do
    options = [
      method: :delete,
      url: "/user/voicemails/#{message_id}"
    ]

    request(client, options)
  end

  @spec report_user_event(Tesla.Client.t(), DateTime.t(), atom(), atom(), map()) :: result()
  def report_user_event(client, timestamp, group, type, data \\ %{}) do
    options = [
      method: :post,
      url: "/user/events",
      body: %{
        timestamp: timestamp,
        group: group,
        type: type,
        data: data
      }
    ]

    request(client, options)
  end

  @spec invoke_custom_public_method(Tesla.Client.t(), String.t(), map()) :: result()
  def invoke_custom_public_method(client, method_name, data) do
    options = [
      method: :post,
      url: "/custom/public/#{method_name}",
      body: data
    ]

    request(client, options)
  end

  @spec invoke_custom_private_method(Tesla.Client.t(), String.t(), map()) :: result()
  def invoke_custom_private_method(client, method_name, data) do
    options = [
      method: :post,
      url: "/custom/private/#{method_name}",
      body: data
    ]

    request(client, options)
  end

  defp request(client, options) do
    case Tesla.request(client, options) do
      {:ok, %Tesla.Env{status: 204}} ->
        {204, %{}}

      # response is empty string and skipped by Tesla.Middleware.JSON
      {:ok, %Tesla.Env{status: code, body: body}} when body == "" ->
        {code, %{}}

      # response is JSON content type and processed by Tesla.Middleware.JSON
      {:ok, %Tesla.Env{status: code, body: body}} when is_map(body) ->
        {code, body}

      # response is not JSON content type - add actual content type to response tuple
      {:ok, env = %Tesla.Env{status: code, body: body}} ->
        content_type = Tesla.get_header(env, "content-type")
        {code, content_type, body}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
