defmodule WebtritAdapterWeb.Api.V1.User.ControllerMapping do
  def api_account_error_to_action_error(:session_id_missed) do
    {:error, :not_found, :session_not_found}
  end

  def api_account_error_to_action_error(:session_id_auth_failed) do
    {:error, :not_found, :session_not_found}
  end

  def api_account_error_to_action_error(:login_and_password_required) do
    {:error, :forbidden, :login_and_password_required}
  end

  def api_account_error_to_action_error(:password_change_required) do
    {:error, :forbidden, :password_change_required}
  end
end
