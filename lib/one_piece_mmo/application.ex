defmodule OnePieceMmo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Registry pour les processus joueurs
      {Registry, keys: :unique, name: OnePieceMmo.PlayerRegistry},
      {Registry, keys: :unique, name: OnePieceMmo.CrewRegistry},

      # Telemetry
      OnePieceMmoWeb.Telemetry,

      # Base de données
      OnePieceMmo.Repo,

      # DNS Cluster
      {DNSCluster, query: Application.get_env(:one_piece_mmo, :dns_cluster_query) || :ignore},

      # PubSub
      {Phoenix.PubSub, name: OnePieceMmo.PubSub},

      # Système de présence
      OnePieceMmoWeb.Presence,

      # Endpoint web
      OnePieceMmoWeb.Endpoint,

      # Superviseurs dynamiques
      {DynamicSupervisor, name: OnePieceMmo.PlayerSupervisor, strategy: :one_for_one},
      {DynamicSupervisor, name: OnePieceMmo.CrewSupervisor, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OnePieceMmo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OnePieceMmoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
