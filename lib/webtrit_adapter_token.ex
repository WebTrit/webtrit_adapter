defmodule WebtritAdapterToken do
  @access_token_max_age_seconds 24 * 60 * 60
  @refresh_token_max_age_seconds 14 * 24 * 60 * 60
  @access_token_secret "access_token_salt"
  @refresh_token_secret "refresh_token_salt"

  @type token_type() :: :access | :refresh

  @spec decrypt(token_type(), binary()) :: term()
  def decrypt(type, token)

  def decrypt(:access, token) do
    Phoenix.Token.decrypt(WebtritAdapterWeb.Endpoint, @access_token_secret, token,
      max_age: @access_token_max_age_seconds
    )
  end

  def decrypt(:refresh, token) do
    Phoenix.Token.decrypt(WebtritAdapterWeb.Endpoint, @refresh_token_secret, token,
      max_age: @refresh_token_max_age_seconds
    )
  end

  @spec encrypt(token_type(), term(), pos_integer()) :: binary()
  def encrypt(type, data, signed_at)

  def encrypt(:access, data, signed_at) do
    Phoenix.Token.encrypt(WebtritAdapterWeb.Endpoint, @access_token_secret, data, signed_at: signed_at)
  end

  def encrypt(:refresh, data, signed_at) do
    Phoenix.Token.encrypt(WebtritAdapterWeb.Endpoint, @refresh_token_secret, data, signed_at: signed_at)
  end
end
