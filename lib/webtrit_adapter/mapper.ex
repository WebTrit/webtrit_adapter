defmodule WebtritAdapter.Mapper do
  @spec i_account_to_user_id(integer()) :: binary()
  def i_account_to_user_id(i_account) do
    :crypto.hash(:sha256, to_string(i_account))
    |> Base.encode64(padding: false)
  end
end
