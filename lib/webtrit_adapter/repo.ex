defmodule WebtritAdapter.Repo do
  use Ecto.Repo,
    otp_app: :webtrit_adapter,
    adapter: Ecto.Adapters.Postgres
end
