defmodule WebtritAdapterWeb.Api.V1.SupportedFunctionality do
  @type t :: :signup | :otpSignin | :passwordSignin | :autoProvision | :recordings | :callHistory | :extensions

  def all_values do
    [
      :signup,
      :otpSignin,
      :passwordSignin,
      :autoProvision,
      :recordings,
      :callHistory,
      :extensions,
      :internalMessaging,
      :smsMessaging
    ]
  end

  def value_description(:signup), do: "supports the creation of new customer accounts"
  def value_description(:otpSignin), do: "allows user authorization via One-Time Password (OTP)"
  def value_description(:passwordSignin), do: "allows user authorization using login and password"
  def value_description(:autoProvision), do: "allows user authorization using config token"
  def value_description(:recordings), do: "provides access to call recordings"
  def value_description(:callHistory), do: "provides access to call history"
  def value_description(:extensions), do: "retrieves the list of other users (contacts)"
  def value_description(:internalMessaging), do: "provides the ability to send and receive instant messages within the system (among system users)"
  def value_description(:smsMessaging), do: "provides the ability to send and receive text messages using the Short Message Service (SMS)"

  def parse("signup"), do: :signup
  def parse("otpSignin"), do: :otpSignin
  def parse("passwordSignin"), do: :passwordSignin
  def parse("autoProvision"), do: :autoProvision
  def parse("recordings"), do: :recordings
  def parse("callHistory"), do: :callHistory
  def parse("extensions"), do: :extensions
  def parse("internalMessaging"), do: :internalMessaging
  def parse("smsMessaging"), do: :smsMessaging
  def parse(_), do: nil
end
