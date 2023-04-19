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
        user_id: "some user_id",
        attempt_count: 42,
        verified: true,
        demo: true,
        ignore: true
      })
      |> WebtritAdapter.Session.create_otp()

    otp
  end
end
