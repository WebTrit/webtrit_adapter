import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.

# Do not print debug messages in production
config :logger, level: :info

config :webtrit_adapter, Config.Adapter.SkipMigrateOnStartup, false

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
