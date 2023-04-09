defmodule WebtritAdapterWeb.Api.HealthCheckController do
  use WebtritAdapterWeb, :controller

  def index(conn, _params) do
    render(conn, wall_clock: :erlang.statistics(:wall_clock))
  end
end
