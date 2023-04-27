defmodule Config.Adapter do
  @spec skip_migrate_on_startup? :: boolean() | nil
  def skip_migrate_on_startup? do
    Application.get_env(:webtrit_adapter, Config.Adapter.SkipMigrateOnStartup)
  end
end
