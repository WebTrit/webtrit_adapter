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

  def not_implemented() do
    {
      :not_implemented,
      {
        """
        The server does not support the functionality required to fulfill the request.
        """,
        "application/json",
        CommonSchema.error_response([
          :functionality_not_implemented
        ])
      }
    }
  end
end
