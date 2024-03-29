defmodule WebtritAdapter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Portabilling.AdministratorSessionManager
  alias Portabilling.AccountSessionManager
  alias Portabilling.DemoAccountManager

  @impl true
  def start(_type, _args) do
    unless WebtritAdapterConfig.skip_migrate_on_startup?() do
      WebtritAdapter.Release.migrate()
    end

    administrator_config = %AdministratorSessionManager.Config{
      administrator_url: WebtritAdapterConfig.portabilling_administrator_url(),
      login: WebtritAdapterConfig.portabilling_administrator_login(),
      token: WebtritAdapterConfig.portabilling_administrator_token(),
      session_regenerate_period: WebtritAdapterConfig.portabilling_administrator_session_regenerate_period()
    }

    account_config = %AccountSessionManager.Config{
      administrator_url: WebtritAdapterConfig.portabilling_administrator_url(),
      account_url: WebtritAdapterConfig.portabilling_account_url(),
      session_invalidate_period: WebtritAdapterConfig.portabilling_account_session_invalidate_period()
    }

    demo_config = %DemoAccountManager.Config{
      administrator_url: WebtritAdapterConfig.portabilling_administrator_url(),
      demo_i_customer: WebtritAdapterConfig.portabilling_demo_i_customer(),
      demo_i_custom_field: WebtritAdapterConfig.portabilling_demo_i_custom_field()
    }

    children = [
      # Start the Telemetry supervisor
      WebtritAdapterWeb.Telemetry,
      # Start the Ecto repository
      WebtritAdapter.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: WebtritAdapter.PubSub},
      # Start the Finch
      {Finch,
       name: WebtritAdapter.Finch,
       pools: [
         default: [conn_opts: [transport_opts: [verify: WebtritAdapterConfig.http_client_ssl_verify_type()]]]
       ]},
      # Start the Portabilling AdministratorSessionManager
      {AdministratorSessionManager, administrator_config},
      # Start the Portabilling AccountSessionManager
      {AccountSessionManager, account_config},
      # Start the Portabilling DemoAccountManager if enabled
      {DemoAccountManager, demo_config},
      # Start the Endpoint (http/https)
      WebtritAdapterWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WebtritAdapter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WebtritAdapterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
