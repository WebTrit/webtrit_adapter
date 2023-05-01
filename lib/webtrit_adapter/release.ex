defmodule WebtritAdapter.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :webtrit_adapter

  def gen_openapi_spec do
    load_app()

    WebtritAdapterWeb.Api.V1.ApiSpec.spec()
    |> OpenApiSpex.OpenApi.to_map(vendor_extensions: false)
    |> OpenApiSpex.OpenApi.json_encoder().encode(pretty: true)
    |> case do
      {:ok, json} ->
        IO.puts(:stdio, json)

      {:error, error} ->
        IO.puts(:stderr, "could not encode OpenAPI Specification, error: #{inspect(error)}")
        exit({:shutdown, 123})
    end
  end

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
