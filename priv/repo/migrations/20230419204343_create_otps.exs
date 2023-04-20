defmodule WebtritAdapter.Repo.Migrations.CreateOtps do
  use Ecto.Migration

  def change do
    create table(:otps, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :i_account, :integer, null: false
      add :attempt_count, :integer, default: 0, null: false
      add :verified, :boolean, default: false, null: false
      add :ignore, :boolean, default: false, null: false
      add :demo, :boolean, default: false, null: false

      timestamps()
    end
  end
end
