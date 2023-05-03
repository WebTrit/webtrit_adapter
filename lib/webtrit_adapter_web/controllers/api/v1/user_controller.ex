defmodule WebtritAdapterWeb.Api.V1.UserController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs

  require Logger
  require OpenApiSpexExt

  alias Portabilling.Api
  alias WebtritAdapter.ApiHelpers
  alias WebtritAdapter.Session
  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.CommonResponse
  alias WebtritAdapterWeb.Api.V1.{CommonSchema, UserSchema}
  alias WebtritAdapterWeb.Api.V1.SessionJSON

  plug OpenApiSpex.Plug.CastAndValidate, render_error: CastAndValidateRenderError

  action_fallback FallbackController

  tags ["user"]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.body_params])
  end

  OpenApiSpexExt.operation(:create,
    summary: "Create a new user",
    description: """
    Create a new user within the **Adaptee**.
    """,
    request_body: {
      """
      Information required for creating a new user.
      """,
      "application/json",
      UserSchema.CreateRequest,
      required: true
    },
    responses: [
      CommonResponse.external_api_issue(),
      ok: {
        """
        User created.

        The response data may vary based on the following scenarios:
        * Adaptee-specific information is returned. This information may not be
          directly used by the application but could be utilized for other
          functionalities. In this scenario, applications open the sign-in
          screen, allowing the user to sign in using the provided/created
          credentials.
        * An OTP code is generated and sent to the user. The `otp_id`
          (identifier of the code) will be used in the `otp_verify` request
          along with the OTP code entered by the user for validation. In this
          scenario, applications open the OTP verification screen, allowing the
          user to sign in using the OTP.
        * An API session is created for the user. In this case, API tokens are
          provided. In this scenario, applications store the received API tokens
          and open the main screen.
        """,
        "application/json",
        UserSchema.CreateResponse
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
          :signup_limit_reached
        ])
      }
    ]
  )

  def create(conn, _params, %{"email" => email} = _body_params) do
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

              email = ApiHelpers.Administrator.get_env_email(conn.assigns.administrator_client)

              conn
              |> put_view(json: SessionJSON)
              |> render(:otp_create, otp: otp, email: email)

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

  def create(_conn, _params, _body_params) do
    unless Portabilling.DemoAccountManager.enabled?() do
      {:error, :method_not_allowed, :signup_disabled}
    else
      {:error, :unprocessable_entity, :validation_error}
    end
  end
end
