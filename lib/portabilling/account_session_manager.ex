defmodule Portabilling.AccountSessionManager do
  use GenServer

  require Logger

  alias Portabilling.Api

  defmodule Config do
    @type t :: %__MODULE__{
            administrator_url: URI.t() | nil,
            account_url: URI.t() | nil,
            session_invalidate_period: non_neg_integer() | nil
          }
    defstruct administrator_url: nil,
              account_url: nil,
              session_invalidate_period: nil
  end

  defmodule State do
    @type t :: %__MODULE__{
            config: Config.t(),
            administrator_client: Tesla.Client.t(),
            account_client: Tesla.Client.t(),
            session_ids: map()
          }
    @enforce_keys [:config, :administrator_client, :account_client]
    defstruct config: nil,
              administrator_client: nil,
              account_client: nil,
              session_ids: %{}
  end

  # Client

  def start_link(%Config{} = config) do
    Logger.debug("starting")

    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @spec get_session_id(integer()) :: binary() | nil
  def get_session_id(i_account) do
    GenServer.call(__MODULE__, {:get_session_id, i_account})
  end

  # Server

  @impl true
  def handle_call(
        {:get_session_id, i_account},
        _from,
        %State{
          config: config,
          administrator_client: administrator_client,
          account_client: account_client,
          session_ids: session_ids
        } = state
      ) do
    case Map.fetch(session_ids, i_account) do
      {:ok, session_id} ->
        {:reply, session_id, state}

      :error ->
        case Api.Administrator.Account.get_account_info(administrator_client, %{
               "i_account" => i_account
             }) do
          {200, %{"account_info" => %{"login" => login, "password" => password}}} ->
            case Api.Account.Session.login(account_client, %{
                   "login" => login,
                   "password" => password
                 }) do
              {200, %{"session_id" => session_id}} ->
                Logger.debug(
                  "login to account realm with login [#{login}] (retrieved by i_account [#{i_account}}]) success"
                )

                schedule_session_invalidate(config.session_invalidate_period, i_account)

                session_ids = Map.put(session_ids, i_account, session_id)

                {:reply, session_id, %{state | session_ids: session_ids}}

              {500, %{"faultcode" => "Server.Session.alert_You_must_change_password"}} ->
                case Api.Account.Session.change_password(account_client, %{
                       "login" => login,
                       "password" => password,
                       "new_password" => generate_new_password(),
                       "establish_new_session" => 1
                     }) do
                  {200, %{"session_id" => session_id}} ->
                    Logger.debug(
                      "login via changed password to account realm with login [#{login}] (retrieved by i_account [#{i_account}}]) success"
                    )

                    schedule_session_invalidate(config.session_invalidate_period, i_account)

                    session_ids = Map.put(session_ids, i_account, session_id)

                    {:reply, session_id, %{state | session_ids: session_ids}}

                  {_, fault} ->
                    Logger.warning("login via changed password to account realm with fault [#{inspect(fault)}]")

                    {:reply, nil, state}
                end

              {_, fault} ->
                Logger.warning("login to account realm with fault [#{inspect(fault)}]")

                {:reply, nil, state}
            end

          {200, %{"account_info" => _}} ->
            Logger.warning(
              "can't login to account realm without login and/or password (retrieved by i_account [#{i_account}}])"
            )

            {:reply, nil, state}

          {_, fault} ->
            Logger.warning("get account info with fault [#{inspect(fault)}]")
            {:reply, nil, state}
        end
    end
  end

  @impl true
  def handle_info({:session_invalidate, i_account}, %State{session_ids: session_ids} = state) do
    # TODO: logout before remove from session_ids
    Logger.debug("invalidate for account by [#{i_account}]")

    session_ids = Map.delete(session_ids, i_account)

    {:noreply, %State{state | session_ids: session_ids}}
  end

  @impl true
  def init(%Config{administrator_url: administrator_url, account_url: account_url})
      when is_nil(administrator_url) or is_nil(account_url) do
    Logger.debug("ignored because config administrator_url and/or account_url is nil")

    :ignore
  end

  @impl true
  def init(%Config{} = config) do
    Logger.debug("started")

    administrator_client = Api.client(config.administrator_url)
    account_client = Api.client(config.account_url)

    state = %State{
      config: config,
      administrator_client: administrator_client,
      account_client: account_client
    }

    {:ok, state}
  end

  @impl true
  def terminate(reason, %State{session_ids: session_ids}) do
    Logger.debug("terminate with reason [#{inspect(reason)}] and with session ids [#{inspect(session_ids)}]")

    :ok
  end

  defp schedule_session_invalidate(session_invalidate_period, i_account) do
    Process.send_after(self(), {:session_invalidate, i_account}, session_invalidate_period)
  end

  @new_password_chars Enum.concat([?a..?z, ?A..?Z, ?0..?9])
  @default_account_password_length 12
  defp generate_new_password(length) when is_integer(length) and length >= 0 do
    1..length
      |> Enum.map(fn _ -> Enum.random(@new_password_chars) end)
      |> List.to_string()
  end
  defp generate_new_password() do
    WebtritAdapterConfig.portabilling_account_password_length() || @default_account_password_length
    |> generate_new_password()
  end
end
