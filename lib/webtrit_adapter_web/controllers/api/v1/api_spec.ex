defmodule WebtritAdapterWeb.Api.V1.ApiSpec do
  @behaviour OpenApiSpex.OpenApi

  alias OpenApiSpex.{Info, Contact, Server, Paths, Components, SecurityScheme}
  alias WebtritAdapterWeb.Router

  @api_v1_prefix "/api/v1"

  @impl true
  def spec do
    %OpenApiSpex.OpenApi{
      info: info(),
      servers: servers(),
      paths: api_v1_paths(),
      components: components()
    }
    |> OpenApiSpex.resolve_schema_modules()
  end

  defp info do
    %Info{
      title: "WebTrit Adapter",
      description: """
      Adapter that translates API requests from WebTrit Core to hosted PBX system,
      which enables users to authenticate, obtain their SIP credentials, and more.
      """,
      contact: %Contact{
        name: "WebTrit Dev",
        url: "https://webtrit.com",
        email: "contact-dev@webtrit.com"
      },
      version: "1.0.0"
    }
  end

  defp servers do
    [
      %Server{url: @api_v1_prefix}
    ]
  end

  defp api_v1_paths do
    Router
    |> Paths.from_router()
    |> Enum.filter(fn {path, _} -> String.starts_with?(path, @api_v1_prefix) end)
    |> Enum.map(fn {@api_v1_prefix <> path, operation} -> {path, operation} end)
    |> Map.new()
  end

  defp components do
    %Components{
      securitySchemes: %{
        "bearerAuth" => %SecurityScheme{
          type: "http",
          scheme: "bearer"
        }
      }
    }
  end
end
