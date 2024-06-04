defmodule WebtritAdapterWeb.Api.V1.ApiSpec do
  @behaviour OpenApiSpex.OpenApi

  alias OpenApiSpex.{Components, Contact, Info, Parameter, Paths, Schema, SecurityScheme, Server, ServerVariable, Tag}
  alias WebtritAdapterWeb.Router

  @api_v1_prefix "/api/v1"

  @impl true
  def spec(opts \\ []) do
    servers_mode = Keyword.get(opts, :servers_mode, :relative)

    %OpenApiSpex.OpenApi{
      info: info(),
      servers: servers(servers_mode),
      paths: api_v1_paths(),
      components: components(),
      tags: tags()
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

      ## Session

      The `access_token` and `refresh_token` format are implicitly determined by the **Adapter** implementation,
      adhering to the following protocol:
      - the `access_token` is a relatively short-lived, reusable token, typically lasting anywhere from an hour to a day or more
      - if during making a protected API call using the current `access_token`, the **Adapter** responds with a `401` status code,
        the caller will initiate the `updateSession` operation, using the `refresh_token` to obtain new `access_token` and `refresh_token`,
        and then retry the original API call
        - if during the `updateSession` operation, the caller receives a response with a non `200` status code,
          it indicates that the `refresh_token` has either expired or been invalidated, and the caller must initiate a new session creation using
          the `createSession` or `createSessionOtp` operations, involving the user
      - the `refresh_token` is a long-lived, single-use token, typically with a duration ranging from a week to a month or more

      Note: An alternative is to not provide a `refresh_token` and make the `access_token` long-lived. In this case,
      when the **Adapter** responds with a `401` status code during a protected API call using this `access_token`,
      the caller can't update the token and must initiate a new session creation using
      the `createSession` or `createSessionOtp` operations, requiring user involvement. Such usage, however, is not recommended.

      ## References

      * [Adapter pattern](https://en.wikipedia.org/wiki/Adapter_pattern)
      """,
      contact: %Contact{
        name: "WebTrit Dev",
        url: "https://webtrit.com",
        email: "contact-dev@webtrit.com"
      },
      version: "1.1.0"
    }
  end

  defp servers(:relative) do
    [
      %Server{url: @api_v1_prefix}
    ]
  end

  defp servers(:absolute) do
    [
      %Server{
        url: "https://{host}" <> @api_v1_prefix,
        variables: %{
          "host" => %ServerVariable{
            description: "Adapter server host",
            default: "adapter.demo.webtrit.com"
          }
        }
      }
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
      },
      parameters: %{
        "TenantID" => %Parameter{
          name: :"X-WebTrit-Tenant-ID",
          in: :header,
          description: """
          Optional filtering.

          This parameter is rarely used and serves for additional filtering in specific cases.
          Note that not all adapter implementations may support this functionality.
          """,
          schema: %Schema{type: :string}
        },
        "AcceptLanguage" => %Parameter{
          name: :"Accept-Language",
          in: :header,
          description: """
          Specifies the preferred languages for the response, ordered by priority.

          The server will attempt to serve content in one of the preferred languages, if available. See RFC-3282
          """,
          schema: %Schema{
            type: :string
          }
        }
      }
    }
  end

  defp tags() do
    [
      %Tag{
        name: "system",
        description: """
        Retrieve information about the features and capabilities of the **Adapter** and **Adaptee**
        """
      },
      %Tag{
        name: "session",
        description: """
        Authenticate users within the **Adaptee**
        """
      },
      %Tag{
        name: "user",
        description: """
        Access user information within the **Adaptee**
        """
      }
    ]
  end
end
