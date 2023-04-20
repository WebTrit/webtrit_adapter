defmodule WebtritAdapter.Session.RefreshToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "refresh_tokens" do
    field :i_account, :integer
    field :usage_counter, :integer, default: 0

    timestamps()
  end

  @doc false
  def create_changeset(refresh_token, attrs) do
    refresh_token
    |> cast(attrs, [:i_account])
    |> validate_required([:i_account])
  end

  @doc false
  def update_changeset(refresh_token, attrs) do
    refresh_token
    |> cast(attrs, [:usage_counter])
    |> validate_required([:usage_counter])
  end
end
