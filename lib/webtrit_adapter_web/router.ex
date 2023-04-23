defmodule WebtritAdapterWeb.Router do
  use WebtritAdapterWeb, :router

  pipeline :swagger do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_v1 do
    plug OpenApiSpex.Plug.PutApiSpec, module: WebtritAdapterWeb.Api.V1.ApiSpec
    plug WebtritAdapterWeb.Api.V1.Plug.AssignPortabillingApiClients
  end

  pipeline :api_v1_auth do
    plug WebtritAdapterWeb.Api.V1.Plug.Auth
  end

  scope "/", WebtritAdapterhWeb do
    pipe_through :swagger

    get "/swagger",
        OpenApiSpex.Plug.SwaggerUI,
        [
          path: "/api/v1/openapi",
          display_operation_id: true,
          default_model_expand_depth: 3
        ],
        alias: false
  end

  scope "/api", WebtritAdapterWeb.Api do
    pipe_through :api

    get "/health-check", HealthCheckController, :index

    scope "/v1", V1 do
      pipe_through [:api_v1]

      get "/openapi", OpenApiSpex.Plug.RenderSpec, [], alias: false
    end

    scope "/v1", V1 do
      pipe_through [:api_v1, :api_v1_auth]

    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:webtrit_adapter, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: WebtritAdapterWeb.Telemetry
    end
  end
end
