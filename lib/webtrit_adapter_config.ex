defmodule WebtritAdapterConfig do
  @spec skip_migrate_on_startup? :: boolean() | nil
  def skip_migrate_on_startup? do
    Application.get_env(:webtrit_core, :skip_migrate_on_startup)
  end

  @spec portabilling_administrator_url :: URI.t() | nil
  def portabilling_administrator_url do
    Application.get_env(:webtrit_adapter, :portabilling_administrator_url)
  end

  @spec portabilling_administrator_login :: String.t() | nil
  def portabilling_administrator_login do
    Application.get_env(:webtrit_adapter, :portabilling_administrator_login)
  end

  @spec portabilling_administrator_token :: String.t() | nil
  def portabilling_administrator_token do
    Application.get_env(:webtrit_adapter, :portabilling_administrator_token)
  end

  @spec portabilling_administrator_session_regenerate_period :: non_neg_integer() | nil
  def portabilling_administrator_session_regenerate_period do
    Application.get_env(:webtrit_adapter, :portabilling_administrator_session_regenerate_period)
  end

  @spec portabilling_account_url :: URI.t() | nil
  def portabilling_account_url do
    Application.get_env(:webtrit_adapter, :portabilling_account_url)
  end

  @spec portabilling_account_session_invalidate_period :: non_neg_integer() | nil
  def portabilling_account_session_invalidate_period do
    Application.get_env(:webtrit_adapter, :portabilling_account_session_invalidate_period)
  end

  @spec portabilling_signin_credentials :: :self_care | :sip
  def portabilling_signin_credentials do
    Application.get_env(:webtrit_adapter, :portabilling_signin_credentials)
  end

  @spec portabilling_demo_i_customer :: integer() | nil
  def portabilling_demo_i_customer do
    Application.get_env(:webtrit_adapter, :portabilling_demo_i_customer)
  end

  @spec portabilling_demo_i_custom_field :: integer() | nil
  def portabilling_demo_i_custom_field do
    Application.get_env(:webtrit_adapter, :portabilling_demo_i_custom_field)
  end

  @spec portabilling_filter_contacts_without_extension :: boolean()
  def portabilling_filter_contacts_without_extension do
    Application.get_env(:webtrit_adapter, :portabilling_filter_contacts_without_extension)
  end

  @spec portasip_host :: String.t()
  def portasip_host do
    Application.get_env(:webtrit_adapter, :portasip_host)
  end

  @spec portasip_port :: non_neg_integer()
  def portasip_port do
    Application.get_env(:webtrit_adapter, :portasip_port)
  end

  @spec janus_sip_force_tcp :: boolean()
  def janus_sip_force_tcp do
    Application.get_env(:webtrit_adapter, :janus_sip_force_tcp)
  end

  @type milliseconds() :: non_neg_integer()

  @spec otp_timeout :: milliseconds()
  def otp_timeout do
    Application.get_env(:webtrit_adapter, :otp_timeout)
  end

  @spec otp_verification_attempts_limit :: non_neg_integer()
  def otp_verification_attempts_limit do
    Application.get_env(:webtrit_adapter, :otp_verification_attempts_limit)
  end

  @spec otp_ignore_accounts :: [String.t()]
  def otp_ignore_accounts do
    Application.get_env(:webtrit_adapter, :otp_ignore_accounts)
  end

  @spec otp_ignore_account?(String.t()) :: boolean()
  def otp_ignore_account?(id) do
    Enum.member?(otp_ignore_accounts(), id)
  end

  @spec disabled_functionalities :: [String.t()]
  def disabled_functionalities do
    Application.get_env(:webtrit_adapter, :disabled_functionalities)
  end

  @spec http_client_ssl_verify_type :: :verify_none | :verify_peer
  def http_client_ssl_verify_type do
    Application.get_env(:webtrit_adapter, :http_client_ssl_verify_type)
  end
end
