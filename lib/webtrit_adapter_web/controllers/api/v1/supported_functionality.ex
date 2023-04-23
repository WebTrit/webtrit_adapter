defmodule WebtritAdapterWeb.Api.V1.SupportedFunctionality do
  def all_values do
    [
      :signup,
      :otpSignin,
      :passwordSignin,
      :recordings,
      :callHistory,
      :extensions
    ]
  end

  def value_description(:signup), do: "supports the creation of new customer accounts"
  def value_description(:otpSignin), do: "allows user authorization via One-Time Password (OTP)"
  def value_description(:passwordSignin), do: "allows user authorization using login and password"
  def value_description(:recordings), do: "provides access to call recordings"
  def value_description(:callHistory), do: "provides access to call history"
  def value_description(:extensions), do: "retrieves the list of other users (contacts)"
end
