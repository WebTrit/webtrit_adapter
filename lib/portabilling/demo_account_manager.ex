defmodule Portabilling.DemoAccountManager do
  use GenServer

  require Logger

  alias Portabilling.Api

  @demo_account_not_activated 0
  @demo_account_set_email 1
  @demo_account_activated 2

  defmodule Config do
    @type t :: %__MODULE__{
            administrator_url: URI.t() | nil,
            demo_i_customer: integer(),
            demo_i_custom_field: integer()
          }
    defstruct administrator_url: nil,
              demo_i_customer: nil,
              demo_i_custom_field: nil
  end

  defmodule State do
    @type t :: %__MODULE__{
            config: Config.t(),
            administrator_client: Tesla.Client.t()
          }
    @enforce_keys [:config, :administrator_client]
    defstruct config: nil,
              administrator_client: nil
  end

  # Client

  def enabled?() do
    Process.whereis(__MODULE__) != nil
  end

  def start_link(%Config{} = config) do
    Logger.debug("starting")

    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @spec retrieve(String.t()) :: {:ok, integer()} | {:error, atom()}
  def retrieve(email) do
    GenServer.call(__MODULE__, {:retrieve, email})
  end

  @spec confirm_activation(integer()) :: :ok | {:error, atom()}
  def confirm_activation(i_account) do
    GenServer.call(__MODULE__, {:confirm_activation, i_account})
  end

  # Server

  @impl true
  def handle_call(
        {:retrieve, email},
        _from,
        %{config: config, administrator_client: administrator_client} = state
      ) do
    case Api.Administrator.Account.get_account_list(administrator_client, %{
           "email" => email,
           "i_customer" => config.demo_i_customer,
           "offset" => 0,
           "limit" => 1
         }) do
      {200, %{"account_list" => [%{"i_account" => i_account}]}} ->
        {:reply, {:ok, i_account}, state}

      {200, %{"account_list" => []}} ->
        case Api.Administrator.Account.get_account_list(administrator_client, %{
               "i_customer" => config.demo_i_customer,
               "offset" => 0,
               "limit" => 1,
               "custom_fields_values" => [
                 %{
                   "i_custom_field" => config.demo_i_custom_field,
                   "db_value" => @demo_account_not_activated
                 }
               ]
             }) do
          {200, %{"account_list" => []}} ->
            {:reply, {:error, :demo_accounts_limit_reached}, state}

          {200, %{"account_list" => [%{"i_account" => i_account}]}} ->
            case Api.Administrator.Account.update_custom_fields_values(administrator_client, %{
                   "custom_fields_values" => [
                     %{
                       "i_custom_field" => config.demo_i_custom_field,
                       "db_value" => @demo_account_set_email
                     }
                   ],
                   "i_account" => i_account
                 }) do
              {200, %{"i_account" => ^i_account}} ->
                case Api.Administrator.Account.update_account(administrator_client, %{
                       "account_info" => %{
                         "i_account" => i_account,
                         "email" => email
                       }
                     }) do
                  {200, %{"i_account" => ^i_account}} ->
                    {:reply, {:ok, i_account}, state}

                  error ->
                    Logger.error("can`t update account email: #{inspect(error)}")
                    {:reply, {:error, :update_email_fail}, state}
                end

              error ->
                Logger.error("can`t update custom field value: #{inspect(error)}")
                {:reply, {:error, :update_custom_field_fail}, state}
            end

          _ ->
            {:reply, {:error, :external_api_issue}, state}
        end

      _ ->
        {:reply, {:error, :external_api_issue}, state}
    end
  end

  @impl true
  def handle_call(
        {:confirm_activation, i_account},
        _from,
        %{config: config, administrator_client: administrator_client} = state
      ) do
    case Api.Administrator.Account.update_custom_fields_values(administrator_client, %{
           "custom_fields_values" => [
             %{
               "i_custom_field" => config.demo_i_custom_field,
               "db_value" => @demo_account_activated
             }
           ],
           "i_account" => i_account
         }) do
      {200, %{"i_account" => ^i_account}} ->
        {:reply, :ok, state}

      error ->
        Logger.error("can`t update custom field value: #{inspect(error)}")
        {:reply, {:error, :update_custom_field_fail}, state}
    end
  end

  @impl true
  def init(%Config{demo_i_customer: demo_i_customer, demo_i_custom_field: demo_i_custom_field})
      when is_nil(demo_i_customer) or is_nil(demo_i_custom_field) do
    Logger.debug("ignored because config demo_i_customer and/or demo_i_custom_field is nil")

    :ignore
  end

  @impl true
  def init(%Config{administrator_url: nil}) do
    Logger.debug("ignored because config administrator_url is nil")

    :ignore
  end

  @impl true
  def init(%Config{} = config) do
    Logger.debug("started with config [#{inspect(config)}]")

    administrator_client = Api.client(config.administrator_url)

    state = %State{
      config: config,
      administrator_client: administrator_client
    }

    {:ok, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.debug("terminate with reason [#{inspect(reason)}] and with state [#{inspect(state)}]")

    :ok
  end
end
