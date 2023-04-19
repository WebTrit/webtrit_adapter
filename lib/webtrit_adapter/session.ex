defmodule WebtritAdapter.Session do
  @moduledoc """
  The Session context.
  """

  import Ecto.Query, warn: false
  alias WebtritAdapter.Repo

  alias WebtritAdapter.Session.Otp

  @doc """
  Returns the list of otps.

  ## Examples

      iex> list_otps()
      [%Otp{}, ...]

  """
  def list_otps do
    Repo.all(Otp)
  end

  @doc """
  Gets a single otp.

  Raises `Ecto.NoResultsError` if the Otp does not exist.

  ## Examples

      iex> get_otp!(123)
      %Otp{}

      iex> get_otp!(456)
      ** (Ecto.NoResultsError)

  """
  def get_otp!(id), do: Repo.get!(Otp, id)

  @doc """
  Creates a otp.

  ## Examples

      iex> create_otp(%{field: value})
      {:ok, %Otp{}}

      iex> create_otp(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_otp(attrs \\ %{}) do
    %Otp{}
    |> Otp.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a otp.

  ## Examples

      iex> update_otp(otp, %{field: new_value})
      {:ok, %Otp{}}

      iex> update_otp(otp, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_otp(%Otp{} = otp, attrs) do
    otp
    |> Otp.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a otp.

  ## Examples

      iex> delete_otp(otp)
      {:ok, %Otp{}}

      iex> delete_otp(otp)
      {:error, %Ecto.Changeset{}}

  """
  def delete_otp(%Otp{} = otp) do
    Repo.delete(otp)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking otp changes.

  ## Examples

      iex> change_otp(otp)
      %Ecto.Changeset{data: %Otp{}}

  """
  def change_otp(%Otp{} = otp, attrs \\ %{}) do
    Otp.changeset(otp, attrs)
  end
end
