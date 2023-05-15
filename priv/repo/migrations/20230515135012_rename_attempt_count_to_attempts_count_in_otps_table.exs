defmodule WebtritAdapter.Repo.Migrations.RenameAttemptCountToAttemptsCountInOtpsTable do
  use Ecto.Migration

  def change do
    rename table(:otps), :attempt_count, to: :attempts_count
  end
end
