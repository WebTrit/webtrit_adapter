defmodule OpenApiSpexExt do
  defmacro schema(body, opts \\ []) do
    quote do
      module_name_parts = Module.split(__MODULE__)

      # +2 to skip "Api" itself and "V*" part
      drop_parts_amount = Enum.find_index(module_name_parts, &(&1 == "Api")) + 2

      title =
        module_name_parts
        |> Enum.drop(drop_parts_amount)
        |> Enum.map(&String.replace_suffix(&1, "Schema", ""))
        |> Enum.join("")

      body_ext = Map.put(unquote(body), :title, title)

      OpenApiSpex.schema(body_ext, unquote(opts))
    end
  end

  @spec operation(action :: atom, spec :: map | keyword) :: any
  defmacro operation(action, spec) do
    quote do
      suffix = __MODULE__ |> Module.split() |> List.last() |> String.replace_suffix("Controller", "")

      prefix = Utils.String.camelize(unquote(action), :lower)

      operation_id = "#{prefix}#{suffix}"

      spec_ext = Keyword.put(unquote(spec), :operation_id, operation_id)

      OpenApiSpex.ControllerSpecs.operation(unquote(action), spec_ext)
    end
  end
end
