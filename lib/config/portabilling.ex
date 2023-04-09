defmodule Config.Portabilling do
  @spec administrator_url :: String.t() | nil
  def administrator_url do
    Application.get_env(:webtrit_adapter, Config.Portabilling.AdministratorUrl)
  end

  @spec administrator_login :: String.t() | nil
  def administrator_login do
    Application.get_env(:webtrit_adapter, Config.Portabilling.AdministratorLogin)
  end

  @spec administrator_token :: String.t() | nil
  def administrator_token do
    Application.get_env(:webtrit_adapter, Config.Portabilling.AdministratorToken)
  end

  @spec administrator_session_regenerate_period :: non_neg_integer() | nil
  def administrator_session_regenerate_period do
    Application.get_env(
      :webtrit_adapter,
      Config.Portabilling.AdministratorSessionRegeneratePeriod
    )
  end

  @spec account_url :: String.t() | nil
  def account_url do
    Application.get_env(:webtrit_adapter, Config.Portabilling.AccountUrl)
  end

  @spec account_session_regenerate_period :: non_neg_integer() | nil
  def account_session_regenerate_period do
    Application.get_env(:webtrit_adapter, Config.Portabilling.AccountSessionRegeneratePeriod)
  end

  @spec signin_credentials :: :self_care | :sip
  def signin_credentials do
    Application.get_env(:webtrit_adapter, Config.Portabilling.SigninCredentials)
  end

  @spec demo_i_customer :: integer() | nil
  def demo_i_customer do
    Application.get_env(:webtrit_adapter, Config.Portabilling.DemoICustomer)
  end

  @spec demo_i_custom_field :: integer() | nil
  def demo_i_custom_field do
    Application.get_env(:webtrit_adapter, Config.Portabilling.DemoICustomField)
  end
end
