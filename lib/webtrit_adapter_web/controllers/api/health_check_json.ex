defmodule WebtritAdapterWeb.Api.HealthCheckJSON do
  def index(%{wall_clock: {total, _since_last_call}}) do
    %{
      total_wall_clock_time: total
    }
  end
end
