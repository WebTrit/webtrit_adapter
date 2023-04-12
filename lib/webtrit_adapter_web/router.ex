defmodule WebtritAdapterWeb.Router do
  use WebtritAdapterWeb, :router

  pipeline :swagger do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug OpenApiSpex.Plug.PutApiSpec, module: WebtritAdapterWeb.Api.V1.ApiSpec
  end

  scope "/", WebtritAdapterhWeb do
    pipe_through :swagger

    get "/swagger", OpenApiSpex.Plug.SwaggerUI, [path: "/api/v1/openapi"], alias: false
  end

  scope "/api", WebtritAdapterWeb.Api do
    pipe_through :api

    get "/health-check", HealthCheckController, :index

    scope "/v1", V1 do
      get "/openapi", OpenApiSpex.Plug.RenderSpec, [], alias: false
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
