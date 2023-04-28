defmodule WebtritAdapterWeb.Api.V1.SessionJSON do
  alias WebtritAdapter.Mapper
  alias WebtritAdapter.Session.{Otp, RefreshToken}

  def otp_create(%{otp: %Otp{id: otp_id}, email: email}) do
    %{
      otp_id: otp_id,
      delivery_channel: "email",
      delivery_from: email
    }
  end

  def create_or_update(%{
        refresh_token: %RefreshToken{
          id: refresh_token_id,
          i_account: i_account,
          usage_counter: usage_counter
        }
      }) do
    current_time_seconds = System.system_time(:second)

    %{
      user_id: Mapper.i_account_to_user_id(i_account),
      access_token:
        WebtritAdapterToken.encrypt(
          :access,
          {:v1, refresh_token_id, i_account},
          current_time_seconds
        ),
      refresh_token:
        WebtritAdapterToken.encrypt(
          :refresh,
          {:v1, refresh_token_id, usage_counter},
          current_time_seconds
        )
    }
  end
end
