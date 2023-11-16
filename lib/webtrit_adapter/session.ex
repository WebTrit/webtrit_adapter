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

  def inc_attempts_count_and_get_otp!(id) do
    field_value_list = Utils.Schema.prepare_autoupdate_field_value_list(Otp)

    queryable =
      from(otp in Otp,
        where: otp.id == ^id,
        update: [set: ^field_value_list, inc: [attempts_count: 1]],
        select: otp
      )

    with {1, [otp]} <- Repo.update_all(queryable, []) do
      otp
    else
      _ -> raise Ecto.NoResultsError, queryable: queryable
    end
  end

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
    |> Otp.create_changeset(attrs)
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
    |> Otp.update_changeset(attrs)
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

  alias WebtritAdapter.Session.RefreshToken

  @doc """
  Returns the list of refresh_tokens.

  ## Examples

      iex> list_refresh_tokens()
      [%RefreshToken{}, ...]

  """
  def list_refresh_tokens do
    Repo.all(RefreshToken)
  end

  @doc """
  Gets a single refresh_token.

  Raises `Ecto.NoResultsError` if the Refresh token does not exist.

  ## Examples

      iex> get_refresh_token!(123)
      %RefreshToken{}

      iex> get_refresh_token!(456)
      ** (Ecto.NoResultsError)

  """
  def get_refresh_token!(id), do: Repo.get!(RefreshToken, id)

  def inc_exact_usage_counter_and_get_refresh_token!(id, usage_counter) do
    field_value_list = Utils.Schema.prepare_autoupdate_field_value_list(RefreshToken)

    queryable =
      from(rt in RefreshToken,
        where: rt.id == ^id,
        where: rt.usage_counter == ^usage_counter,
        update: [set: ^field_value_list, inc: [usage_counter: 1]],
        select: rt
      )

    with {1, [refresh_token]} <- Repo.update_all(queryable, []) do
      refresh_token
    else
      _ -> raise Ecto.NoResultsError, queryable: queryable
    end
  end

  @doc """
  Creates a refresh_token.

  ## Examples

      iex> create_refresh_token(%{field: value})
      {:ok, %RefreshToken{}}

      iex> create_refresh_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_refresh_token(attrs \\ %{}) do
    %RefreshToken{}
    |> RefreshToken.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a refresh_token.

  ## Examples

      iex> update_refresh_token(refresh_token, %{field: new_value})
      {:ok, %RefreshToken{}}

      iex> update_refresh_token(refresh_token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_refresh_token(%RefreshToken{} = refresh_token, attrs) do
    refresh_token
    |> RefreshToken.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a refresh_token.

  ## Examples

      iex> delete_refresh_token(refresh_token)
      {:ok, %RefreshToken{}}

      iex> delete_refresh_token(refresh_token)
      {:error, %Ecto.Changeset{}}

  """
  def delete_refresh_token(%RefreshToken{} = refresh_token) do
    Repo.delete(refresh_token)
  end

  def delete_refresh_token(refresh_token_id) do
    %RefreshToken{id: refresh_token_id}
    |> Repo.delete()
  end

  def delete_all_refresh_token(i_account) do
    from(rt in RefreshToken,
      where: rt.i_account == ^i_account
    )
    |> Repo.delete_all()
  end
end
