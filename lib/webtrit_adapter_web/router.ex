defmodule WebtritAdapterWeb.Router do
  use WebtritAdapterWeb, :router

  pipeline :swagger do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json", "mp3", "wav", "zip"]
  end

  pipeline :api_v1 do
    plug OpenApiSpex.Plug.PutApiSpec, module: WebtritAdapterWeb.Api.V1.ApiSpec
    plug WebtritAdapterWeb.Api.V1.Plug.AssignPortabillingApiClients

    plug Cldr.Plug.PutLocale,
      apps: [:cldr],
      from: [:accept_language],
      cldr: WebtritAdapter.Cldr
  end

  pipeline :api_v1_auth do
    plug WebtritAdapterWeb.Api.V1.Plug.Auth
  end

  scope "/", WebtritAdapterhWeb do
    pipe_through :swagger

    get "/swagger-ui",
        OpenApiSpex.Plug.SwaggerUI,
        [
          path: "/api/v1/openapi",
          layout: "BaseLayout",
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

      resources "/system-info", System.InfoController, only: [:show], singleton: true

      scope "/session" do
        post "/", SessionController, :create
        patch "/", SessionController, :update
        post "/otp-create", SessionController, :otp_create
        post "/otp-verify", SessionController, :otp_verify
        post "/auto-provision", SessionController, :auto_provision
      end

      resources "/user", UserController, only: [:create], singleton: true
    end

    scope "/v1", V1 do
      pipe_through [:api_v1, :api_v1_auth]

      scope "/session" do
        delete "/", SessionController, :delete
      end

      scope "/user", User do
        resources "/", InfoController, only: [:show, :delete], singleton: true
        resources "/contacts", ContactController, only: [:index, :show], params: "user_id"
        resources "/history", HistoryController, only: [:index]
        resources "/recordings", RecordingController, only: [:show], param: "recording_id"

        scope "/voicemails" do
          resources "/", VoicemailController, only: [:index, :show, :delete], param: "message_id"
          patch "/:message_id", VoicemailController, :update, param: "message_id"
          get "/:message_id/attachment", VoicemailController, :show_attachment, param: "message_id"
        end
      end
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
