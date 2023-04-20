defmodule WebtritAdapter.Session.Otp do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "otps" do
    field :i_account, :integer
    field :attempt_count, :integer, default: 0
    field :verified, :boolean, default: false
    field :ignore, :boolean, default: false
    field :demo, :boolean, default: false

    timestamps()
  end

  @doc false
  def create_changeset(otp, attrs) do
    otp
    |> cast(attrs, [:i_account, :ignore, :demo])
    |> validate_required([:i_account])
  end

  @doc false
  def update_changeset(otp, attrs) do
    otp
    |> cast(attrs, [:attempt_count, :verified])
    |> validate_number(:attempt_count, greater_than_or_equal_to: 0)
  end
end
