defmodule OnePieceMmo.Repo do
  use Ecto.Repo,
    otp_app: :one_piece_mmo,
    adapter: Ecto.Adapters.Postgres
end
