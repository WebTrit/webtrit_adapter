defmodule Utils.Map do
  @type key() :: any()
  @type value() :: any()

  @spec deep_filter(map(), ({key(), value()} -> as_boolean(term()))) :: map()
  def deep_filter(map, fun)

  def deep_filter(map, fun) when is_struct(map) and is_function(fun, 1) do
    map
  end

  def deep_filter(map, fun) when is_map(map) and is_function(fun, 1) do
    map
    |> Enum.map(fn {k, v} ->
      case v do
        nested_map when is_map(nested_map) -> {k, deep_filter(nested_map, fun)}
        _ -> {k, v}
      end
    end)
    |> Enum.filter(fun)
    |> Enum.into(%{})
  end

  @spec deep_filter_blank_values(map()) :: map()
  def deep_filter_blank_values(map) when is_map(map) do
    deep_filter(map, &blank_value?/1)
  end

  defp blank_value?({_k, nil}), do: false
  defp blank_value?({_k, ""}), do: false
  defp blank_value?({_k, _v}), do: true
end
