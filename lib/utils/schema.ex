defmodule Utils.Schema do
  def prepare_autogenerate_field_value_list(model), do: prepare_auto_field_value_list(model, :autogenerate)

  def prepare_autoupdate_field_value_list(model), do: prepare_auto_field_value_list(model, :autoupdate)

  defp prepare_auto_field_value_list(model, auto) do
    Enum.map(model.__schema__(auto), fn {fields, {module, function, args}} ->
      Enum.map(fields, fn field ->
        {field, apply(module, function, args)}
      end)
    end)
    |> List.flatten()
  end
end
