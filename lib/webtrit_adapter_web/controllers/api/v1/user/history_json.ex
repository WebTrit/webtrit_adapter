defmodule WebtritAdapterWeb.Api.V1.User.HistoryJSON do
  alias WebtritAdapterWeb.Api.V1.User.Mapping

  def index(%{
        xdr_list: xdr_list,
        page: page,
        items_per_page: items_per_page,
        items_total: items_total
      }) do
    %{
      items: for(xdr <- xdr_list, do: data(xdr)),
      pagination: %{
        page: page,
        items_per_page: items_per_page,
        items_total: items_total
      }
    }
  end

  defp data(xdr) do
    %{
      callee: xdr["CLD"],
      caller: xdr["CLI"],
      direction: Mapping.direction(xdr),
      status: Mapping.call_status(xdr),
      disconnected_reason: xdr["disconnect_reason"],
      connect_time: Mapping.connect_time(xdr),
      duration: xdr["charged_quantity"],
      recording_id: if(Mapping.call_recording_exist(xdr), do: xdr["i_xdr"], else: nil)
    }
    |> Utils.Map.deep_filter_blank_values()
  end
end
