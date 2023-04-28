defmodule WebtritAdapterWeb.Api.V1.Plug.Auth do
  import Phoenix.Controller
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    case get_auth_token(conn) do
      {:ok, access_token} ->
        case decrypt_access_token(access_token) do
          {:ok, {:v1, refresh_token_id, i_account}} ->
            conn
            |> assign(:refresh_token_id, refresh_token_id)
            |> assign(:i_account, i_account)

          {:error, :invalid} ->
            unauthorized(conn, :access_token_invalid)

          {:error, :expired} ->
            unauthorized(conn, :access_token_expired)

          _ ->
            unauthorized(conn, :unknown)
        end

      {:error, code} ->
        unauthorized(conn, code)
    end
  end

  defp unauthorized(conn, code) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: WebtritAdapterWeb.Api.V1.ErrorJSON)
    |> render(:error, code: code)
    |> halt()
  end

  defp get_auth_token(conn) do
    with [authorization_header] <- get_req_header(conn, "authorization") do
      get_token_from_header(authorization_header)
    else
      _ -> {:error, :authorization_header_missing}
    end
  end

  defp get_token_from_header(authorization_header) do
    with [_, token] <- Regex.run(~r/Bearer\:?\s+(.*)\s*$/i, authorization_header) do
      {:ok, token}
    else
      _ -> {:error, :bearer_credentials_missing}
    end
  end

  defp decrypt_access_token(token) do
    WebtritAdapterToken.decrypt(:access, token)
  end
end
