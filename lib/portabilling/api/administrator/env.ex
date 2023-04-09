defmodule Portabilling.Api.Administrator.Env do
  import Portabilling.Api

  def get_env_info(client, %{} = params \\ %{}) do
    perform_contextual(client, params)
  end
end
