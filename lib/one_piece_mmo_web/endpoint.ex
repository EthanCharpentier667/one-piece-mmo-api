defmodule OnePieceMmoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :one_piece_mmo

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_one_piece_mmo_key",
    signing_salt: "Fc1zxTJz",
    same_site: "Lax"
  ]

  # Configuration WebSocket pour le MMO
  socket "/socket", OnePieceMmoWeb.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :one_piece_mmo,
    gzip: false,
    only: OnePieceMmoWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :one_piece_mmo
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  # Configuration CORS pour UE5
  plug Corsica,
    origins: "*",
    allow_headers: :all,
    allow_methods: :all

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug OnePieceMmoWeb.Router
end
