defmodule WebtritAdapter.SessionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WebtritAdapter.Session` context.
  """

  @doc """
  Generate a otp.
  """
  def otp_fixture(attrs \\ %{}) do
    {:ok, otp} =
      attrs
      |> Enum.into(%{
        i_account: 1,
        demo: true,
        ignore: true
      })
      |> WebtritAdapter.Session.create_otp()

    otp
  end

  @doc """
  Generate a refresh_token.
  """
  def refresh_token_fixture(attrs \\ %{}) do
    {:ok, refresh_token} =
      attrs
      |> Enum.into(%{
        i_account: 1
      })
      |> WebtritAdapter.Session.create_refresh_token()

    refresh_token
  end
end
