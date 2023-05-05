defmodule Portabilling.AdministratorSessionManager do
  use GenServer

  require Logger

  alias Portabilling.Api

  defmodule Config do
    @type t :: %__MODULE__{
            administrator_url: URI.t() | nil,
            login: String.t() | nil,
            token: String.t() | nil,
            session_regenerate_period: non_neg_integer() | nil
          }
    defstruct administrator_url: nil,
              login: nil,
              token: nil,
              session_regenerate_period: nil
  end

  defmodule State do
    @type t :: %__MODULE__{
            config: Config.t(),
            administrator_client: Tesla.Client.t(),
            session_id: term()
          }
    @enforce_keys [:config, :administrator_client]
    defstruct config: nil,
              administrator_client: nil,
              session_id: nil
  end

  # Client

  def start_link(%Config{} = config) do
    Logger.debug("starting")

    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @spec get_session_id() :: binary()
  def get_session_id() do
    GenServer.call(__MODULE__, :get_session_id)
  end

  # Server

  @impl true
  def handle_call(:get_session_id, _from, %State{session_id: session_id} = state) do
    {:reply, session_id, state}
  end

  @impl true
  def handle_info(
        :session_regenerate,
        %State{config: config, administrator_client: administrator_client} = state
      ) do
    Logger.debug("regenerate")

    case Api.Administrator.Session.login(administrator_client, %{
           "login" => config.login,
           "token" => config.token
         }) do
      {200, %{"session_id" => session_id}} ->
        Logger.debug("re-login success")

        schedule_session_regenerate(config.session_regenerate_period)

        {:noreply, %State{state | session_id: session_id}}

      {_, fault} ->
        {:stop, {:login_error, fault}, state}
    end
  end

  @impl true
  def init(%Config{administrator_url: nil}) do
    Logger.debug("ignored because config administrator_url is nil")

    :ignore
  end

  @impl true
  def init(%Config{} = config) do
    Logger.debug("started")

    administrator_client = Api.client(config.administrator_url)

    case Api.Administrator.Session.login(administrator_client, %{
           "login" => config.login,
           "token" => config.token
         }) do
      {200, %{"session_id" => session_id}} ->
        Logger.debug("login success")

        schedule_session_regenerate(config.session_regenerate_period)

        state = %State{
          config: config,
          administrator_client: administrator_client,
          session_id: session_id
        }

        {:ok, state}

      {_, fault} ->
        {:stop, {:login_error, fault}}
    end
  end

  @impl true
  def terminate({:login_error, fault}, _state) do
    Logger.warn("terminate with fault [#{inspect(fault)}]")
    :ok
  end

  @impl true
  def terminate(reason, %State{administrator_client: administrator_client, session_id: session_id}) do
    Logger.debug("terminate with reason [#{inspect(reason)}]")

    case Api.Administrator.Session.logout(administrator_client, %{
           "session_id" => session_id
         }) do
      {200, %{"success" => 1}} ->
        Logger.debug("logout success")
        :ok

      {200, %{"success" => 0}} ->
        Logger.debug("logout failure")
        :ok

      {_, fault} ->
        Logger.warn("logout with fault [#{inspect(fault)}]")
        :error
    end
  end

  defp schedule_session_regenerate(session_regenerate_period) do
    Process.send_after(self(), :session_regenerate, session_regenerate_period)
  end
end
