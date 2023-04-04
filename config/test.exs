import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :webtrit_adapter, WebtritAdapterWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/TevDVo2i7aJovFBh80WwxoNVtF3dNy0hpOtQtKuQsxjRaj8gN+oHjx9gcaJW++v",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
