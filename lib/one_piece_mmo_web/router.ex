defmodule OnePieceMmoWeb.Router do
  use OnePieceMmoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Route simple pour la page de test
  get "/test", OnePieceMmoWeb.PageController, :test
  get "/debug", OnePieceMmoWeb.PageController, :debug

  scope "/api", OnePieceMmoWeb do
    pipe_through :api

    get "/status", GameController, :status
    get "/world", GameController, :world_info
    get "/players", GameController, :online_players
    get "/player/:player_id", GameController, :player_stats
    get "/crew/:crew_id", GameController, :crew_info
    get "/crews", GameController, :all_crews
    get "/leaderboard", GameController, :leaderboard
  end  # Enable LiveDashboard in development
  if Application.compile_env(:one_piece_mmo, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: OnePieceMmoWeb.Telemetry
    end
  end
end
