defmodule WebtritAdapter.MixProject do
  use Mix.Project

  def project do
    [
      app: :webtrit_adapter,
      version: "0.13.0-alpha.1",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      elixirc_options: [
        warnings_as_errors: true
      ],
      releases: [
        webtrit_adapter: [
          include_executables_for: [:unix]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {WebtritAdapter.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.12"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.1"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.7"},
      {:tz, "~> 0.26"},
      {:open_api_spex, "~> 3.18"},
      {:finch, "~> 0.18"},
      {:tesla, "~> 1.8"},
      {:ex_cldr, "~> 2.37"},
      {:ex_cldr_plugs, "~> 1.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "gen.openapi.spec.v1": [
        "openapi.spec.json --spec WebtritAdapterWeb.Api.V1.ApiSpec --pretty=true --vendor-extensions=false _openapi_spec/webtrit_adapter_v1.json"
      ]
    ]
  end
end
