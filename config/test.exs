import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :one_piece_mmo, OnePieceMmo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "one_piece_mmo_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :one_piece_mmo, OnePieceMmoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "FGF3yEbZYd1jmnq77qh1BqJ7trQDhZICShNCQVJ9jTaq2qG/AbbCuuiPxJJ0PfV+",
  server: false

# In test we don't send emails
config :one_piece_mmo, OnePieceMmo.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
