defmodule Portabilling.Api.Administrator.Generic do
  import Portabilling.Api

  def get_version(client, %{} = params \\ %{}) do
    perform_contextual(client, params)
  end
end
