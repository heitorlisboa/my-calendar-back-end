defmodule MyCalendarWeb.Router do
  use MyCalendarWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug MyCalendar.Guardian.AuthPipeline
  end

  scope "/api", MyCalendarWeb do
    pipe_through :api

    post "/users", UserController, :register
    post "/session/new", SessionController, :new
    post "/session/refresh", SessionController, :refresh

    get "/task_day", TaskDayController, :index
  end

  scope "/api", MyCalendarWeb do
    pipe_through [:api, :auth]

    post "/task", TaskController, :create
    put "/task/:id", TaskController, :update
    patch "/task/:id", TaskController, :update
    delete "/task/:id", TaskController, :delete
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

      live_dashboard "/dashboard", metrics: MyCalendarWeb.Telemetry
    end
  end
end
