defmodule WebtritAdapterWeb.Api.V1.FallbackController do
  use WebtritAdapterWeb, :controller

  def call(conn, {:error, status, code, details}) do
    conn
    |> put_status(status)
    |> put_view(json: WebtritAdapterWeb.Api.V1.ErrorJSON)
    |> render(:error, code: code, details: details)
  end

  def call(conn, {:error, status, code}) do
    call(conn, {:error, status, code, nil})
  end
end
