defmodule Config.Janussip do
  @spec sips :: boolean()
  def sips do
    Application.get_env(:webtrit_adapter, Config.Janussip.Sips)
  end

  @spec force_tcp :: boolean()
  def force_tcp do
    Application.get_env(:webtrit_adapter, Config.Janussip.ForceTcp)
  end
end
