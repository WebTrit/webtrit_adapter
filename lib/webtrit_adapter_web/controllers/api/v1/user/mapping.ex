defmodule WebtritAdapterWeb.Api.V1.User.Mapping do
  import Bitwise

  def display_name(account_info) do
    cond do
      account_info["extension_name"] ->
        account_info["extension_name"]

      account_info["firstname"] || account_info["lastname"] ->
        "#{account_info["firstname"]} #{account_info["lastname"]}"
        |> String.trim()

      true ->
        nil
    end
  end

  def balance_type(account_info) do
    billing_model_to_balance_type(
      account_info["billing_model"],
      account_info["master_billing_model"],
      account_info["i_account_balance_control_type"]
    )
  end

  @spec billing_model_to_balance_type(integer, integer | nil, integer | nil) ::
          :inapplicable | :postpaid | :prepaid | :unknown
  defp billing_model_to_balance_type(bm, mbm, bct)

  defp billing_model_to_balance_type(-1, _, _), do: :prepaid
  defp billing_model_to_balance_type(0, _, _), do: :inapplicable
  defp billing_model_to_balance_type(1, _, 3), do: :postpaid
  defp billing_model_to_balance_type(2, _, _), do: :inapplicable
  defp billing_model_to_balance_type(4, -1, _), do: :prepaid
  defp billing_model_to_balance_type(4, 1, 3), do: :postpaid
  defp billing_model_to_balance_type(_, _, _), do: :unknown

  @spec alias_list_to_numbers(list()) :: list() | nil
  def alias_list_to_numbers(alias_list)

  def alias_list_to_numbers([]), do: nil

  def alias_list_to_numbers(alias_list) when is_list(alias_list) do
    alias_list
    |> Enum.map(& &1["id"])
    |> Enum.map(&List.first(String.split(&1, "@", parts: 2)))
    |> Enum.filter(&(&1 != nil && String.length(&1) != 0))
    |> Enum.dedup()
    |> Enum.sort()
  end

  def sip_status(account) do
    sip_status_to_sip_status(account["sip_status"])
  end

  @spec sip_status_to_sip_status(integer) :: :unknown | :registered | :notregistered
  defp sip_status_to_sip_status(v)

  defp sip_status_to_sip_status(1), do: :registered
  defp sip_status_to_sip_status(0), do: :notregistered
  defp sip_status_to_sip_status(_), do: :unknown

  def direction(cdr) do
    bit_flags = cdr["bit_flags"]

    case bit_flags &&& 12 do
      4 ->
        :outgoing

      8 ->
        :incoming

      12 ->
        :forwarded

      _ ->
        :unknown
    end
  end

  def call_recording_exist(cdr) do
    bit_flags = cdr["bit_flags"]
    (bit_flags &&& 64) !== 0
  end

  def call_status(xdr) do
    cause =
      if is_number(xdr["disconnect_cause"]) do
        is_number(xdr["disconnect_cause"])
      else
        String.to_integer(xdr["disconnect_cause"])
      end

    failed = xdr["failed"] == 1

    setup_time = xdr["setup_time"]

    xdr_to_call_status(failed, cause, setup_time)
  end

  @spec xdr_to_call_status(
          failed :: boolean(),
          disconnect_cause :: integer(),
          setup_time :: integer()
        ) ::
          :accepted | :declined | :missed | :error
  defp xdr_to_call_status(failed, disconnect_cause, setup_time)

  defp xdr_to_call_status(true, 16, _), do: :declined
  defp xdr_to_call_status(true, 19, _), do: :missed
  @setup_time_limit 2000
  defp xdr_to_call_status(false, 16, setup_time) when setup_time < @setup_time_limit,
    do: :accepted

  defp xdr_to_call_status(false, 16, _), do: :declined
  defp xdr_to_call_status(_, _, _), do: :error

  def connect_time(xdr, time_zone) do
    xdr["connect_time"] |> xdr_time_to_datetime!(time_zone)
  end

  def disconnect_time(xdr, time_zone) do
    xdr["disconnect_time"] |> xdr_time_to_datetime!(time_zone)
  end

  defp xdr_time_to_datetime!(xdr_time, time_zone) do
    xdr_time |> NaiveDateTime.from_iso8601!() |> DateTime.from_naive!(time_zone)
  end
end
