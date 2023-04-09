defmodule Portabilling.Api.Account.CDR do
  import Portabilling.Api

  def get_call_recording(client, i_account, %{} = params) do
    perform_contextual(
      client,
      i_account,
      params
    )
  end
end
