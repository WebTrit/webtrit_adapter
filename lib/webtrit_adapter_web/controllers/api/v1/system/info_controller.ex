defmodule WebtritAdapterWeb.Api.V1.System.InfoController do
  use WebtritAdapterWeb, :controller
  use OpenApiSpex.ControllerSpecs
  use OpenApiSpexExt

  alias Portabilling.Api
  alias WebtritAdapterWeb.Api.V1.CastAndValidateRenderError
  alias WebtritAdapterWeb.Api.V1.FallbackController
  alias WebtritAdapterWeb.Api.V1.CommonResponse
  alias WebtritAdapterWeb.Api.V1.System.InfoSchema
  alias WebtritAdapterWeb.Api.V1.SupportedFunctionality

  plug OpenApiSpex.Plug.CastAndValidate, render_error: CastAndValidateRenderError

  action_fallback FallbackController

  tags ["system"]
  OpenApiSpexExt.parameters("$ref": "#/components/parameters/TenantID")

  OpenApiSpexExt.operation(:show,
    summary: "Retrieve system and Adaptee information",
    description: """
    Retrieve information about the **Adapter** and the connected **Adaptee**.

    The primary focus of this information is on the supported functionalities and capabilities provided by the system.
    """,
    responses: [
      CommonResponse.external_api_issue(),
      ok: {
        """
        Provides information about the **Adapter** and the connected **Adaptee**, including their supported functionalities and capabilities.
        """,
        "application/json",
        InfoSchema.ShowResponse
      }
    ]
  )

  def show(conn, _params) do
    name = Application.spec(:webtrit_adapter, :description) |> to_string()
    version = Application.spec(:webtrit_adapter, :vsn) |> to_string()

    disabled =
      WebtritAdapterConfig.disabled_functionalities()
      |> Enum.map(&SupportedFunctionality.parse/1)
      |> Enum.reject(&is_nil/1)

    supported = SupportedFunctionality.all_values() -- disabled
    # Currently, the Portabilling does not support sign in with a token for autoprovision
    supported = supported -- [:autoProvision]

    case Api.Administrator.Generic.get_version(conn.assigns.administrator_client) do
      {200, %{"version" => portabilling_version}} ->
        conn
        |> json(%{
          name: name,
          version: version,
          supported: supported,
          custom: %{
            adaptee_name: "PortaBilling",
            adaptee_version: portabilling_version
          }
        })

      _ ->
        {:error, :internal_server_error, :external_api_issue}
    end
  end
end
