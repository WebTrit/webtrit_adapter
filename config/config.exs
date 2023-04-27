# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

config :webtrit_adapter,
  ecto_repos: [WebtritAdapter.Repo]

# Configures the endpoint
config :webtrit_adapter, WebtritAdapterWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: WebtritAdapterWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: WebtritAdapter.PubSub,
  live_view: [signing_salt: "5dZUI3zP"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$date $time [$level] $metadata$message\n",
  metadata: [:module, :request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Set Tesla global adapter
config :tesla,
       :adapter,
       {Tesla.Adapter.Finch, name: WebtritAdapter.Finch, pool_timeout: 60_000, receive_timeout: 15_000}

config :webtrit_adapter, Config.Adapter.SkipMigrateOnStartup, true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
