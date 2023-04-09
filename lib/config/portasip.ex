defmodule Config.Portasip do
  @spec host :: String.t()
  def host do
    Application.get_env(:webtrit_adapter, Config.Portasip.Host)
  end

  @spec port :: non_neg_integer()
  def port do
    Application.get_env(:webtrit_adapter, Config.Portasip.Port)
  end
end
