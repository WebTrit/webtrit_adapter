defmodule WebtritAdapter.ApiHelpers.Administrator do
  alias Portabilling.Api

  def get_env_email(client) do
    case Api.Administrator.Env.get_env_info(client) do
      {200, %{"env_info" => %{"email" => email}}} ->
        email

      _ ->
        nil
    end
  end
end
