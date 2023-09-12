defmodule RuntimeConfig do
  @maximum_sequentialy_index 1000

  defmodule EnvValueError do
    @enforce_keys [:name]
    defexception [:name, :explanation]

    @impl true
    def message(%EnvValueError{name: name, explanation: explanation}) do
      message = "environment variable #{inspect(name)} value incorrect"

      case explanation do
        nil ->
          message

        value when is_binary(value) ->
          message <> " - #{value}"

        value ->
          message <> " - #{inspect(value)}"
      end
    end
  end

  @spec get_env(String.t()) :: nil | String.t()
  def get_env(name) do
    case System.get_env(name) do
      "" ->
        nil

      value ->
        value
    end
  end

  @spec get_env_from_allowed_values(String.t(), [String.t()]) :: nil | String.t()
  def get_env_from_allowed_values(name, allowed_values) do
    case get_env(name) do
      nil ->
        nil

      value ->
        if value in allowed_values do
          value
        else
          raise EnvValueError,
            name: name,
            explanation: "expected one of #{inspect(allowed_values)}, got #{inspect(value)}"
        end
    end
  end

  @spec get_env_as_integer(String.t()) :: nil | integer()
  def get_env_as_integer(name) do
    case get_env(name) do
      nil ->
        nil

      value ->
        case Integer.parse(value) do
          {integer, ""} ->
            integer

          _ ->
            raise EnvValueError, name: name, explanation: "expected integer value, got #{inspect(value)}"
        end
    end
  end

  @spec get_env_as_non_neg_integer(String.t()) :: nil | non_neg_integer()
  def get_env_as_non_neg_integer(name) do
    case get_env_as_integer(name) do
      nil ->
        nil

      integer when integer >= 0 ->
        integer

      integer ->
        raise EnvValueError, name: name, explanation: "expected non-negative integer value, got #{inspect(integer)}"
    end
  end

  @spec get_env_as_boolean(String.t()) :: nil | boolean()
  def get_env_as_boolean(name) do
    case get_env(name) do
      "true" ->
        true

      "false" ->
        false

      nil ->
        nil

      value ->
        raise EnvValueError, name: name, explanation: "expected \"true\" or \"false\", got #{inspect(value)}"
    end
  end

  @spec get_env_as_uri(String.t()) :: nil | URI.t()
  def get_env_as_uri(name) do
    case get_env(name) do
      nil ->
        nil

      value ->
        URI.parse(value)
    end
  end

  @spec get_env_as_logger_level(String.t()) :: nil | Logger.level()
  def get_env_as_logger_level(name) do
    case get_env_from_allowed_values(name, [
           "emergency",
           "alert",
           "critical",
           "error",
           "warning",
           "notice",
           "info",
           "debug"
         ]) do
      nil ->
        nil

      value ->
        String.to_atom(value)
    end
  end

  @spec get_env_as_sequentialy_indexed_list(String.t(), integer) :: list()
  def get_env_as_sequentialy_indexed_list(name, first_index \\ 1) do
    Enum.reduce_while(first_index..@maximum_sequentialy_index, [], fn index, acc ->
      case System.get_env("#{name}__#{index}") do
        nil ->
          {:halt, acc}

        value ->
          {:cont, acc ++ [value]}
      end
    end)
  end

  defmodule EnvError do
    @enforce_keys [:name]
    defexception [:name, :example]

    @impl true
    def message(%EnvError{name: name, example: example}) do
      message = "could not get environment variable #{inspect(name)} because it is not set or is empty"

      case example do
        nil ->
          message

        value ->
          message <> " (example value: #{inspect(value)})"
      end
    end
  end

  @spec get_env!(String.t(), String.t() | nil) :: String.t()
  def get_env!(name, example \\ nil) do
    get_env(name) || raise EnvError, name: name, example: example
  end

  @spec get_env_from_allowed_values!(String.t(), [String.t()]) :: String.t()
  def get_env_from_allowed_values!(name, allowed_values) do
    get_env_from_allowed_values(name, allowed_values) || raise EnvError, name: name
  end

  @spec get_env_as_integer!(String.t(), String.t() | nil) :: integer()
  def get_env_as_integer!(name, example \\ nil) do
    get_env_as_integer(name) || raise EnvError, name: name, example: example
  end

  @spec get_env_as_non_neg_integer!(String.t(), String.t() | nil) :: non_neg_integer()
  def get_env_as_non_neg_integer!(name, example \\ nil) do
    get_env_as_non_neg_integer(name) || raise EnvError, name: name, example: example
  end

  defmodule EnvsError do
    @enforce_keys [:names]
    defexception [:names]

    @impl true
    def message(%{names: names}) do
      "environment variables #{inspect(names)} must be set and be not empty simultaneously"
    end
  end

  @spec get_env_as_uri!(String.t(), String.t() | nil, [String.t()] | nil) :: URI.t()
  def get_env_as_uri!(name, example \\ nil, allowed_schemes \\ nil) do
    uri = get_env_as_uri(name) || raise EnvError, name: name, example: example

    if allowed_schemes == nil || uri.scheme in allowed_schemes do
      uri
    else
      raise EnvValueError,
        name: name,
        explanation: "expected one of schemes #{inspect(allowed_schemes)}, got #{inspect(uri.scheme)}"
    end
  end

  @spec get_env_as_http_uri!(String.t(), String.t() | nil) :: URI.t()
  def get_env_as_http_uri!(name, example \\ nil) do
    get_env_as_uri!(name, example, ["http", "https"])
  end

  @spec get_env_as_ws_uri!(String.t(), String.t() | nil) :: URI.t()
  def get_env_as_ws_uri!(name, example \\ nil) do
    get_env_as_uri!(name, example, ["ws", "wss"])
  end

  @spec ensure_get_all_or_none_envs!([String.t()]) :: nil | [String.t()]
  def ensure_get_all_or_none_envs!(names) when is_list(names) do
    envs =
      Enum.map(names, fn name ->
        get_env(name)
      end)

    cond do
      Enum.all?(envs, &is_nil/1) ->
        nil

      Enum.any?(envs, &is_nil/1) ->
        raise EnvsError, names: names

      true ->
        envs
    end
  end

  @spec ensure_get_all_or_none_envs_as_integer!([String.t()]) :: nil | [integer()]
  def ensure_get_all_or_none_envs_as_integer!(names) when is_list(names) do
    case ensure_get_all_or_none_envs!(names) do
      nil ->
        nil

      envs ->
        Enum.zip(names, envs)
        |> Enum.map(fn {name, value} ->
          case Integer.parse(value) do
            {integer, ""} ->
              integer

            _ ->
              raise EnvValueError, name: name, explanation: "expected integer value, got #{inspect(value)}"
          end
        end)
    end
  end

  defmacro config_env_try(get_env_code) do
    quote do
      try do
        unquote(get_env_code)
      rescue
        e ->
          case config_env() do
            :dev = env ->
              IO.puts([to_string(env), ": ", Exception.message(e)])

            :test ->
              nil

            _ ->
              reraise e, __STACKTRACE__
          end
      end
    end
  end
end
