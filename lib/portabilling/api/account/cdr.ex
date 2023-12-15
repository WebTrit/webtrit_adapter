defmodule Portabilling.Api.Account.CDR do
  import Portabilling.Api

  @type headers_map() :: map()

  @spec get_call_recording(any(), nil | integer(), map()) ::
          {:error, any()} | {Tesla.Env.status(), headers_map(), Tesla.Env.body()}
  def get_call_recording(client, i_account, %{} = params) do
    perform_contextual(
      client,
      i_account,
      params,
      true
    )
  end
end
