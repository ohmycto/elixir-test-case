defmodule GeoTasksWeb.Router do
  use GeoTasksWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug GeoTasksWeb.Plugs.AuthPlug
  end

  scope "/api/v1", GeoTasksWeb, as: :api_v1 do
    pipe_through :api

    resources "/tasks", TaskController, only: [:index, :create] do
      put "/pick", TaskController, :pick, as: :pick
      put "/finish", TaskController, :finish, as: :finish
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: GeoTasksWeb.Telemetry
    end
  end
end
