defmodule WebtritAdapter.Session.Otp do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "otps" do
    field :user_id, :string
    field :attempt_count, :integer, default: 0
    field :verified, :boolean, default: false
    field :demo, :boolean, default: false
    field :ignore, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(otp, attrs) do
    otp
    |> cast(attrs, [:user_id, :attempt_count, :verified, :ignore, :demo])
    |> validate_required([:user_id, :attempt_count, :verified, :ignore, :demo])
  end
end
