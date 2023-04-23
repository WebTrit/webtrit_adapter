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
      The **Adapter** translates API requests from **WebTrit Core** to the target hosted PBX system or BSS,
      which will be referred to as the **Adaptee**. This translation enables users to authenticate,
      obtain their SIP credentials, and retrieve other necessary information.

      ## Terminology

      * **Adapter** - the current system
      * **Adaptee** - the target hosted PBX system or BSS
      * **OTP** (One-Time Password) - a unique, temporary password sent to the user via a predefined delivery method,
        such as email, SMS, etc.
      * **CDR** (Call Detail Record) - a record of a call, including the caller, callee, duration, etc.

      ## References

      * [Adapter pattern](https://en.wikipedia.org/wiki/Adapter_pattern)
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
