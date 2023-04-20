defmodule WebtritAdapter.Repo.Migrations.CreateRefreshTokens do
  use Ecto.Migration

  def change do
    create table(:refresh_tokens) do
      add :i_account, :integer, null: false
      add :usage_counter, :integer, default: 0, null: false

      timestamps()
    end
  end
end
