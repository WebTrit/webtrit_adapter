defmodule WebtritAdapterWeb.Api.V1.CommonResponse do
  alias WebtritAdapterWeb.Api.V1.CommonSchema

  def unauthorized() do
    {
      :unauthorized,
      {
        """
        Unauthorized: The request was not authorized for one of the following reasons:
        - `access_token` not provided
        - `access_token` incorrect or outdated
        - session associated with the `access_token` is signed out
        """,
        "application/json",
        CommonSchema.error_response([
          :authorization_header_missing,
          :bearer_credentials_missing,
          :access_token_invalid,
          :access_token_expired,
          :unknown
        ])
      }
    }
  end

  def forbidden() do
    {
      :forbidden,
      {
        """
        Forbidden: The request was forbidden for one of the following reasons:
        - login to the account realm requires both login and password (PortaBilling specific)
        - login to the account realm requires a password change (PortaBilling specific)
        """,
        "application/json",
        CommonSchema.error_response([
          :login_and_password_required,
          :password_change_required
        ])
      }
    }
  end

  def session_not_found() do
    {
      :not_found,
      {
        """
        Not Found: The session could not be located.
        """,
        "application/json",
        CommonSchema.error_response([
          :session_not_found
        ])
      }
    }
  end

  def user_not_found() do
    {
      :not_found,
      {
        """
        Not Found: The user could not be located.
        """,
        "application/json",
        CommonSchema.error_response([
          :user_not_found
        ])
      }
    }
  end

  def session_and_user_not_found() do
    {
      :not_found,
      {
        """
        Not Found: Either the session or the user could not be located.
        """,
        "application/json",
        CommonSchema.error_response([
          :session_not_found,
          :user_not_found
        ])
      }
    }
  end

  def unprocessable(additional_codes_enum \\ []) do
    {
      :unprocessable_entity,
      {
        """
        Unprocessable Entity.
        """,
        "application/json",
        CommonSchema.error_response(
          [
            :validation_error
          ] ++ additional_codes_enum
        )
      }
    }
  end

  def external_api_issue() do
    {
      :internal_server_error,
      {
        """
        Internal Server Error.
        """,
        "application/json",
        CommonSchema.error_response([
          :external_api_issue
        ])
      }
    }
  end

  def functionality_not_implemented() do
    {
      :not_implemented,
      {
        """
        Not Implemented: The requested functionality is not supported.
        """,
        "application/json",
        CommonSchema.error_response([
          :functionality_not_implemented
        ])
      }
    }
  end
end
