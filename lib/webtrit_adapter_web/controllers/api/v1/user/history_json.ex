defmodule WebtritAdapterWeb.Api.V1.User.HistoryJSON do
  alias WebtritAdapterWeb.Api.V1.User.JSONMapping

  def index(%{
        xdr_list: xdr_list,
        time_zone: time_zone,
        page: page,
        items_per_page: items_per_page,
        items_total: items_total
      }) do
    %{
      items: for(xdr <- xdr_list, do: data(xdr, time_zone)),
      pagination: %{
        page: page,
        items_per_page: items_per_page,
        items_total: items_total
      }
    }
  end

  defp data(xdr, time_zone) do
    %{
      call_id: xdr["call_id"],
      callee: xdr["CLD"],
      caller: xdr["CLI"],
      direction: JSONMapping.direction(xdr),
      status: JSONMapping.call_status(xdr),
      disconnect_reason: xdr["disconnect_reason"],
      connect_time: JSONMapping.connect_time(xdr, time_zone),
      disconnect_time: JSONMapping.disconnect_time(xdr, time_zone),
      duration: xdr["charged_quantity"],
      recording_id: if(JSONMapping.call_recording_exist(xdr), do: xdr["i_xdr"], else: nil)
    }
    |> Utils.Map.deep_filter_blank_values()
  end
end
