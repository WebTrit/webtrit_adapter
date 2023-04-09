defmodule Config.Otp do
  @type milliseconds() :: non_neg_integer()

  @spec timeout :: milliseconds()
  def timeout do
    Application.get_env(:webtrit_adapter, Config.Otp.Timeout)
  end

  @spec verification_attempt_limit :: non_neg_integer()
  def verification_attempt_limit do
    Application.get_env(:webtrit_adapter, Config.Otp.VerificationAttemptLimit)
  end

  @spec ignore_accounts :: [String.t()]
  def ignore_accounts do
    Application.get_env(:webtrit_adapter, Config.Otp.IgnoreAccounts)
  end

  @spec ignore_account?(String.t()) :: boolean()
  def ignore_account?(id) do
    Enum.member?(ignore_accounts(), id)
  end
end
