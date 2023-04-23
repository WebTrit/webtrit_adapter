defmodule WebtritAdapterWeb.Api.V1.SessionController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs

  import WebtritAdapter.Mapper, only: [i_account_to_user_id: 1]

  require Logger
  require OpenApiSpexExt

  alias Portabilling.Api
  alias WebtritAdapter.Session
  alias WebtritAdapter.Session.Otp
  alias WebtritAdapter.Session.RefreshToken
  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.CommonResponse
  alias WebtritAdapterWeb.Api.V1.{CommonSchema, SessionSchema}

  plug(OpenApiSpex.Plug.CastAndValidate, render_error: CastAndValidateRenderError)

  action_fallback(FallbackController)

  tags(["session"])

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.body_params])
  end

  OpenApiSpexExt.operation(:otp_create,
    summary: "Generate and send an OTP to the user",
    description: """
    Generates an OTP for the user within the **Adaptee** and sends it
    to the user through a predefined delivery channel (e.g., email, SMS, etc.).
    This request can be used to sign in an existing user or sign up a new user,
    if the functionality is supported by the **Adaptee**.
    """,
    request_body: {
      """
      Identification of the user for whom an OTP will be generated and sent.
      """,
      "application/json",
      SessionSchema.OtpCreateRequest,
      required: true
    },
    responses: [
      CommonResponse.external_api_issue(),
      ok: {
        """
        The OTP code was generated and sent to the user.

        The `otp_id` (identifier of the code) will be used in the `otp_verify`
        request along with the OTP code entered by the user for validation.
        """,
        "application/json",
        SessionSchema.OtpCreateResponse
      },
      not_found: {
        """
        Not Found. The user was not found.
        """,
        "application/json",
        CommonSchema.error_response([
          :user_not_found
        ])
      },
      method_not_allowed: {
        """
        Method Not Allowed. Signup behavior disabled.
        """,
        "application/json",
        CommonSchema.error_response([
          :signup_disabled
        ])
      },
      unprocessable_entity: {
        """
        Unprocessable Entity.
        """,
        "application/json",
        CommonSchema.error_response([
          :validation_error,
          :delivery_channel_unspecified,
          :signup_limit_reached
        ])
      }
    ]
  )

  def otp_create(conn, _params, %{user_email: email} = _body_params) do
    unless Portabilling.DemoAccountManager.enabled?() do
      {:error, :method_not_allowed, :signup_disabled}
    else
      case Portabilling.DemoAccountManager.retrieve(email) do
        {:ok, i_account} ->
          case Api.Administrator.AccessControl.create_otp(
                 conn.assigns.administrator_client,
                 %{"id" => i_account}
               ) do
            {200, %{"success" => 1}} ->
              {:ok, otp} = Session.create_otp(%{i_account: i_account, demo: true})

              render_otp_create_responce(conn, otp)

            {500, %{"faultcode" => "Server.AccessControl.empty_rec_and_bcc"}} ->
              {:error, :unprocessable_entity, :delivery_channel_unspecified}

            _ ->
              {:error, :internal_server_error, :external_api_issue}
          end

        {:error, :demo_accounts_limit_reached} ->
          {:error, :unprocessable_entity, :signup_limit_reached}

        _ ->
          {:error, :internal_server_error, :external_api_issue}
      end
    end
  end

  def otp_create(conn, _params, %{user_ref: user_ref} = _body_params) do
    case Api.Administrator.Account.get_account_info(
           conn.assigns.administrator_client,
           %{"id" => user_ref}
         ) do
      {200, %{"account_info" => %{"i_account" => i_account}}} ->
        ignore = Config.Otp.ignore_account?(user_ref)

        case skip_create_otp(ignore) ||
               Api.Administrator.AccessControl.create_otp(
                 conn.assigns.administrator_client,
                 %{"id" => i_account}
               ) do
          {200, %{"success" => 1}} ->
            {:ok, otp} = Session.create_otp(%{i_account: i_account, ignore: ignore})

            render_otp_create_responce(conn, otp)

          {500, %{"faultcode" => "Server.AccessControl.empty_rec_and_bcc"}} ->
            {:error, :unprocessable_entity, :delivery_channel_unspecified}

          _ ->
            {:error, :internal_server_error, :external_api_issue}
        end

      {200, %{}} ->
        {:error, :not_found, :user_not_found}

      _ ->
        {:error, :internal_server_error, :external_api_issue}
    end
  end

  OpenApiSpexExt.operation(:otp_verify,
    summary: "Verify the OTP and sign in the user",
    description: """
    Validates the provided OTP code by the user and sign in if successful.
    """,
    request_body: {
      "User OTP verify credentials.",
      "application/json",
      SessionSchema.OtpVerifyRequest,
      required: true
    },
    responses: [
      CommonResponse.external_api_issue(),
      ok: {
        """
        User is verified, an API session is created, and API tokens are provided.
        """,
        "application/json",
        SessionSchema.Response
      },
      not_found: {
        """
        Not Found. `opt_id` was not found.
        """,
        "application/json",
        CommonSchema.error_response([
          :otp_id_not_found
        ])
      },
      unprocessable_entity: {
        """
        Unprocessable Entity.
        """,
        "application/json",
        CommonSchema.error_response([
          :validation_error,
          :otp_id_verified,
          :otp_id_verification_attempts_exceeded,
          :code_incorrect
        ])
      }
    ]
  )

  def otp_verify(conn, _params, %{otp_id: otp_id, code: code} = _body_params) do
    attempt_limit = Config.Otp.verification_attempt_limit()

    case Session.inc_attempt_count_and_get_otp!(otp_id) do
      %Otp{verified: true} ->
        {:error, :unprocessable_entity, :otp_id_verified}

      %Otp{attempt_count: attempt_count} when attempt_count > attempt_limit ->
        {:error, :unprocessable_entity, :otp_id_verification_attempt_exceeded}

      %Otp{i_account: i_account, ignore: ignore, demo: demo} = otp ->
        case skip_verify_otp(ignore) ||
               Api.Administrator.AccessControl.verify_otp(
                 conn.assigns.administrator_client,
                 %{"one_time_password" => code}
               ) do
          {200, %{"success" => 1}} ->
            case (demo && Portabilling.DemoAccountManager.confirm_activation(i_account)) || :ok do
              :ok ->
                {:ok, _} = Session.update_otp(otp, %{verified: true})

                {:ok, refresh_token} = Session.create_refresh_token(%{i_account: i_account})

                render_session_responce(conn, refresh_token)

              _ ->
                {:error, :internal_server_error, :external_api_issue}
            end

          {200, %{"success" => 0}} ->
            {:error, :unprocessable_entity, :code_incorrect}

          _ ->
            {:error, :internal_server_error, :external_api_issue}
        end
    end
  rescue
    Ecto.NoResultsError -> {:error, :not_found, :otp_id_not_found}
  end

  OpenApiSpexExt.operation(:create,
    summary: "Sign in the user",
    description: """
    This is an alternative sign-in method for the **Adaptee** that do not support OTP.

    The absence of OTP support is indicated when the `#{:otpSignin}` value is not present
    in the `supported` property of the `GeneralSystemInfoResponse`.
    """,
    request_body: {
      "User credentials.",
      "application/json",
      SessionSchema.CreateRequest,
      required: true
    },
    responses: [
      CommonResponse.unprocessable([
        :credentials_incorrect
      ]),
      CommonResponse.external_api_issue(),
      ok: {
        """
        User is verified, an API session is created, and API tokens are provided.
        """,
        "application/json",
        SessionSchema.Response
      }
    ]
  )

  def create(conn, _params, %{login: login, password: password} = _body_params) do
    {login_key, password_key} =
      case Config.Portabilling.signin_credentials() do
        :self_care ->
          {"login", "password"}

        :sip ->
          {"id", "h323_password"}
      end

    case Api.Administrator.Account.get_account_info(
           conn.assigns.administrator_client,
           %{login_key => login}
         ) do
      {200, %{"account_info" => %{^password_key => ^password, "i_account" => i_account}}} ->
        {:ok, refresh_token} = Session.create_refresh_token(%{i_account: i_account})

        render_session_responce(conn, refresh_token)

      {200, %{}} ->
        {:error, :unprocessable_entity, :credentials_incorrect}

      _ ->
        {:error, :internal_server_error, :external_api_issue}
    end
  end

  OpenApiSpexExt.operation(:update,
    summary: "Refresh user's API session and retrieve new tokens",
    description: """
    The API `access_token` has an expiration date, so the API session needs to be
    updated periodically. To do this, exchange the `refresh_token`
    (initially provided along with the access token) for new tokens
    (`access_token` and `refresh_token`). This should be done before the
    `refresh_token` expires to prevent the user from having to manually sign
    in again.
    """,
    request_body: {
      "Update credentials.",
      "application/json",
      SessionSchema.UpdateRequest,
      required: true
    },
    responses: [
      CommonResponse.session_not_found(),
      CommonResponse.external_api_issue(),
      ok: {
        """
        The user's API session is refreshed, and new tokens with extended lifetime are provided.
        """,
        "application/json",
        SessionSchema.Response
      },
      unprocessable_entity: {
        """
        Unprocessable Entity.
        """,
        "application/json",
        CommonSchema.error_response([
          :validation_error,
          :refresh_token_invalid,
          :refresh_token_expired,
          :unknown
        ])
      }
    ]
  )

  def update(
        conn,
        _params,
        %{refresh_token: refresh_token} = _body_params
      ) do
    case refresh_token_decrypt(refresh_token) do
      {:ok, {:v1, refresh_token_id, usage_counter}} ->
        refresh_token = Session.inc_exact_usage_counter_and_get_refresh_token!(refresh_token_id, usage_counter)

        render_session_responce(conn, refresh_token)

      {:error, :invalid} ->
        {:error, :unprocessable_entity, :refresh_token_invalid}

      {:error, :expired} ->
        {:error, :unprocessable_entity, :refresh_token_expired}

      _ ->
        {:error, :unprocessable_entity, :unknown}
    end
  rescue
    Ecto.NoResultsError -> {:error, :not_found, :session_not_found}
  end

  OpenApiSpexExt.operation(:delete,
    security: [%{"bearerAuth" => []}],
    summary: "Sign out the user",
    description: """
    The user's API session is deleted.
    """,
    responses: [
      CommonResponse.unauthorized(),
      CommonResponse.session_not_found(),
      CommonResponse.external_api_issue(),
      no_content: "Signed out."
    ]
  )

  def delete(conn, _params, _body_params) do
    refresh_token_id = conn.assigns.refresh_token_id

    {:ok, _} = Session.delete_refresh_token(refresh_token_id)

    send_resp(conn, :no_content, "")
  rescue
    Ecto.StaleEntryError -> {:error, :not_found, :session_not_found}
  end

  # Helpers

  defp api_administrator_get_env_email(client) do
    case Api.Administrator.Env.get_env_info(client) do
      {200, %{"env_info" => %{"email" => email}}} ->
        email

      _ ->
        nil
    end
  end

  defp skip_create_otp(true) do
    {200, %{"success" => 1}}
  end

  defp skip_create_otp(false) do
    nil
  end

  defp skip_verify_otp(true) do
    {200, %{"success" => 1}}
  end

  defp skip_verify_otp(false) do
    nil
  end

  defp access_token_encrypt(data, signed_at),
    do: WebtritAdatperToken.encrypt(:access, data, signed_at)

  defp refresh_token_encrypt(data, signed_at),
    do: WebtritAdatperToken.encrypt(:refresh, data, signed_at)

  defp refresh_token_decrypt(token), do: WebtritAdatperToken.decrypt(:refresh, token)

  defp render_otp_create_responce(conn, %Otp{id: otp_id}) do
    email = api_administrator_get_env_email(conn.assigns.administrator_client)

    conn
    |> json(%{
      otp_id: otp_id,
      delivery_channel: "email",
      delivery_from: email
    })
  end

  defp render_session_responce(conn, %RefreshToken{
         id: refresh_token_id,
         i_account: i_account,
         usage_counter: usage_counter
       }) do
    current_time_seconds = System.system_time(:second)

    conn
    |> json(%{
      user_id: i_account_to_user_id(i_account),
      access_token:
        access_token_encrypt(
          {:v1, refresh_token_id, i_account},
          current_time_seconds
        ),
      refresh_token:
        refresh_token_encrypt(
          {:v1, refresh_token_id, usage_counter},
          current_time_seconds
        )
    })
  end
end