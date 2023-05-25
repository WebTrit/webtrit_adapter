defmodule OpenApiSpexExt do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :shared_parameters, accumulate: true)

      @before_compile OpenApiSpexExt
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def shared_parameters, do: @shared_parameters
    end
  end

  defmacro parameters(parameters) do
    quote do
      @shared_parameters unquote(parameters)
    end
  end

  defmacro schema(body, opts \\ []) do
    quote do
      title =
        OpenApiSpexExt.api_module_name_parts(__MODULE__)
        |> Enum.map(&String.replace_suffix(&1, "Schema", ""))
        |> Enum.join("")

      body_ext = Map.put(unquote(body), :title, title)

      OpenApiSpex.schema(body_ext, unquote(opts))
    end
  end

  @spec operation(action :: atom, spec :: map | keyword) :: any
  defmacro operation(action, spec) do
    quote do
      spec = Map.new(unquote(spec))

      spec =
        spec
        |> OpenApiSpexExt.concatenated_shared_parameters_with_parameters(__MODULE__)
        |> OpenApiSpexExt.put_new_operation_id_in_operation(unquote(action), __MODULE__)
        |> OpenApiSpexExt.put_new_title_to_error_responses_in_operation(unquote(action), __MODULE__)

      OpenApiSpex.ControllerSpecs.operation(unquote(action), spec)
    end
  end

  def concatenated_shared_parameters_with_parameters(spec, module) do
    shared_parameters = Module.get_attribute(module, :shared_parameters, []) |> List.flatten()
    concatenated_parameters = shared_parameters ++ Map.get(spec, :parameters, [])

    Map.put(spec, :parameters, concatenated_parameters)
  end

  def api_module_name_parts(module) do
    module_name_parts = Module.split(module)

    # +2 to skip "Api" itself and "V*" part
    drop_parts_amount = Enum.find_index(module_name_parts, &(&1 == "Api")) + 2

    Enum.drop(module_name_parts, drop_parts_amount)
  end

  def put_new_operation_id_in_operation(spec, action, module) do
    action_parts = String.split(to_string(action), "_")
    {prefix, action_parts} = List.pop_at(action_parts, -1)

    {prefix, quantity} =
      case prefix do
        "index" -> {"get", "List"}
        "show" -> {"get", ""}
        prefix -> {prefix, ""}
      end

    suffix =
      api_module_name_parts(module)
      |> Enum.map(&String.replace_suffix(&1, "Controller", ""))
      |> Enum.join("")

    post_suffix = action_parts |> Enum.map(&String.capitalize/1) |> Enum.join()

    operation_id = "#{prefix}#{suffix}#{post_suffix}#{quantity}"

    Map.put_new(spec, :operation_id, operation_id)
  end

  def put_new_title_to_error_responses_in_operation(
        %{operation_id: operation_id, responses: responses} = spec,
        _action,
        _module
      )
      when is_list(responses) or is_map(responses) do
    responses =
      Map.new(responses, fn
        {status, {description, mime, %OpenApiSpex.Schema{title: nil, allOf: [common | _]} = schema}}
        when is_atom(common) ->
          title =
            "#{Utils.String.camelize(operation_id)}#{Utils.String.camelize(status)}#{List.last(Module.split(common))}"

          {status, {description, mime, %{schema | title: title}}}

        element ->
          element
      end)

    %{spec | responses: responses}
  end
end
