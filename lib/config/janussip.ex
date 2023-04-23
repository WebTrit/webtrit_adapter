defmodule Config.Janussip do
  @spec force_tcp :: boolean()
  def force_tcp do
    Application.get_env(:webtrit_adapter, Config.Janussip.ForceTcp)
  end
end
