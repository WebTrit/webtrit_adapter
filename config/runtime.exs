import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/webtrit_adapter start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :webtrit_adapter, WebtritAdapterWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :webtrit_adapter, WebtritAdapter.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4001")

  config :webtrit_adapter, WebtritAdapterWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :webtrit_adapter, WebtritAdapterWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your endpoint, ensuring
  # no data is ever sent via http, always redirecting to https:
  #
  #     config :webtrit_adapter, WebtritAdapterWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.
end

require RuntimeConfig

case RuntimeConfig.get_env_as_logger_level("LOGGER_LEVEL") do
  nil ->
    nil

  logger_level ->
    config :logger, level: logger_level
end

case RuntimeConfig.get_env_as_boolean("SKIP_MIGRATE_ON_STARTUP") do
  nil ->
    nil

  skip_migrate_on_startup ->
    config :webtrit_adapter,
           :skip_migrate_on_startup,
           skip_migrate_on_startup
end

RuntimeConfig.config_env_try do
  case RuntimeConfig.get_env_as_http_uri!("PORTABILLING_ADMINISTRATOR_URL", "https://demo.portaone.com/rest") do
    portabilling_administrator_url ->
      config :webtrit_adapter,
             :portabilling_administrator_url,
             portabilling_administrator_url
  end
end

RuntimeConfig.config_env_try do
  case RuntimeConfig.get_env!("PORTABILLING_ADMINISTRATOR_LOGIN", "webtrit") do
    portabilling_administrator_login ->
      config :webtrit_adapter,
             :portabilling_administrator_login,
             portabilling_administrator_login
  end
end

RuntimeConfig.config_env_try do
  case RuntimeConfig.get_env!("PORTABILLING_ADMINISTRATOR_TOKEN", "00000000-0000-0000-0000-000000000000") do
    portabilling_administrator_token ->
      config :webtrit_adapter,
             :portabilling_administrator_token,
             portabilling_administrator_token
  end
end

RuntimeConfig.config_env_try do
  case RuntimeConfig.get_env_as_non_neg_integer!("PORTABILLING_ADMINISTRATOR_SESSION_REGENERATE_PERIOD", "43200000") do
    portabilling_administrator_session_regenerate_period ->
      config :webtrit_adapter,
             :portabilling_administrator_session_regenerate_period,
             portabilling_administrator_session_regenerate_period
  end
end

RuntimeConfig.config_env_try do
  case RuntimeConfig.get_env_as_http_uri!("PORTABILLING_ACCOUNT_URL", "https://demo.portaone.com:8445/rest") do
    portabilling_account_url ->
      config :webtrit_adapter, :portabilling_account_url, portabilling_account_url
  end
end

RuntimeConfig.config_env_try do
  case RuntimeConfig.get_env_as_non_neg_integer!("PORTABILLING_ACCOUNT_SESSION_INVALIDATE_PERIOD", "43200000") do
    portabilling_account_session_invalidate_period ->
      config :webtrit_adapter,
             :portabilling_account_session_invalidate_period,
             portabilling_account_session_invalidate_period
  end
end

RuntimeConfig.config_env_try do
  case RuntimeConfig.get_env_from_allowed_values!("PORTABILLING_SIGNIN_CREDENTIALS", ["self-care", "sip"]) do
    signin_credentials ->
      config :webtrit_adapter,
             :portabilling_signin_credentials,
             signin_credentials |> String.replace("-", "_") |> String.to_atom()
  end
end

RuntimeConfig.config_env_try do
  case RuntimeConfig.ensure_get_all_or_none_envs_as_integer!([
         "PORTABILLING_DEMO_I_CUSTOMER",
         "PORTABILLING_DEMO_I_CUSTOM_FIELD"
       ]) do
    nil ->
      nil

    [portabilling_demo_i_customer, portabilling_demo_i_custom_field] ->
      config :webtrit_adapter,
             :portabilling_demo_i_customer,
             portabilling_demo_i_customer

      config :webtrit_adapter,
             :portabilling_demo_i_custom_field,
             portabilling_demo_i_custom_field
  end
end

RuntimeConfig.config_env_try do
  case RuntimeConfig.get_env!("PORTASIP_HOST", "sip.webtrit.com") do
    portasip_host ->
      config :webtrit_adapter,
             :portasip_host,
             portasip_host
  end
end

case RuntimeConfig.get_env_as_non_neg_integer("PORTASIP_PORT") do
  portasip_port ->
    config :webtrit_adapter,
           :portasip_port,
           portasip_port
end

case RuntimeConfig.get_env_as_boolean("JANUS_SIP_FORCE_TCP") do
  janus_sip_force_tcp ->
    config :webtrit_adapter,
           :janus_sip_force_tcp,
           janus_sip_force_tcp
end

RuntimeConfig.config_env_try do
  case RuntimeConfig.get_env_as_non_neg_integer!("OTP_TIMEOUT") do
    otp_timeout ->
      config :webtrit_adapter,
             :otp_timeout,
             otp_timeout
  end
end

RuntimeConfig.config_env_try do
  case RuntimeConfig.get_env_as_non_neg_integer!("OTP_VERIFICATION_ATTEMPTS_LIMIT") do
    otp_verification_attempts_limit ->
      config :webtrit_adapter,
             :otp_verification_attempts_limit,
             otp_verification_attempts_limit
  end
end

case RuntimeConfig.get_env("OTP_IGNORE_ACCOUNTS") do
  nil ->
    config :webtrit_adapter,
           :otp_ignore_accounts,
           []

  otp_ignore_accounts ->
    otp_ignore_accounts_list = otp_ignore_accounts |> String.split(~r/[,;]/, trim: true) |> Enum.map(&String.trim/1)

    config :webtrit_adapter,
           :otp_ignore_accounts,
           otp_ignore_accounts_list
end

case RuntimeConfig.get_env("DISABLED_FUNCTIONALITIES") do
  nil ->
    config :webtrit_adapter,
           :disabled_functionalities,
           []

  disabled_functionalities ->
    disabled_functionalities_list =
      disabled_functionalities |> String.split(~r/[,;]/, trim: true) |> Enum.map(&String.trim/1)

    config :webtrit_adapter,
           :disabled_functionalities,
           disabled_functionalities_list
end
