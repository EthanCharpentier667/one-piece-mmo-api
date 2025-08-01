defmodule OnePieceMmo.Player do
  use GenServer

  alias OnePieceMmo.Accounts
  alias OnePieceMmo.Accounts.User

  defstruct [
    :id,
    :name,
    :position,
    :level,
    :experience,
    :bounty,
    :crew_id,
    :stats,
    :devil_fruit,
    :created_at,
    :last_active
  ]

  # API Publique
  def start_player(player_id, player_name) do
    case DynamicSupervisor.start_child(
      OnePieceMmo.PlayerSupervisor,
      {__MODULE__, {player_id, player_name}}
    ) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end

  def start_link({player_id, player_name}) do
    GenServer.start_link(__MODULE__, {player_id, player_name}, name: via_tuple(player_id))
  end

  def update_position(player_id, position) do
    GenServer.cast(via_tuple(player_id), {:update_position, position})
  end

  def join_crew(player_id, crew_id) do
    GenServer.cast(via_tuple(player_id), {:join_crew, crew_id})
  end

  def leave_crew(player_id) do
    GenServer.cast(via_tuple(player_id), {:leave_crew})
  end

  def get_state(player_id) do
    GenServer.call(via_tuple(player_id), :get_state)
  end

  def add_experience(player_id, exp) do
    GenServer.cast(via_tuple(player_id), {:add_experience, exp})
  end

  # Registry
  defp via_tuple(player_id) do
    {:via, Registry, {OnePieceMmo.PlayerRegistry, player_id}}
  end

  # Callbacks GenServer
  @impl true
  def init({player_id, player_name}) do
    player = load_or_create_player(player_id, player_name)

    # Programmer des sauvegardes périodiques (toutes les 30 secondes)
    :timer.send_interval(30_000, :save_player)

    {:ok, player}
  end

  # Charger le joueur depuis la DB ou en créer un nouveau
  defp load_or_create_player(player_id, player_name) do
    case Accounts.get_user_by_player_id(player_id) do
      nil ->
        # Créer un nouveau joueur
        player = create_new_player(player_id, player_name)

        # Sauvegarder en DB
        user_attrs = User.from_player_state(player)
        Accounts.create_user(user_attrs)

        player

      user ->
        # Charger depuis la DB
        player = User.to_player_state(user)

        # Mettre à jour last_login et s'assurer que created_at/last_active sont définis
        updated_player = %{player |
          created_at: player.created_at || user.inserted_at,
          last_active: DateTime.utc_now()
        }

        Accounts.update_user(user, %{last_login: DateTime.utc_now()})

        updated_player
    end
  end

  defp create_new_player(player_id, player_name) do
    %__MODULE__{
      id: player_id,
      name: player_name,
      position: %{x: 0.0, y: 0.0, z: 0.0, island: "starter_island"},
      level: 1,
      experience: 0,
      bounty: 0,
      crew_id: nil,
      stats: %{strength: 10, speed: 10, endurance: 10, intelligence: 10},
      devil_fruit: nil,
      created_at: DateTime.utc_now(),
      last_active: DateTime.utc_now()
    }
  end

  @impl true
  def handle_cast({:update_position, position}, player) do
    new_player = %{player | position: position, last_active: DateTime.utc_now()}
    {:noreply, new_player}
  end

  @impl true
  def handle_cast({:join_crew, crew_id}, player) do
    new_player = %{player | crew_id: crew_id}
    {:noreply, new_player}
  end

  @impl true
  def handle_cast({:leave_crew}, player) do
    new_player = %{player | crew_id: nil}
    {:noreply, new_player}
  end

  @impl true
  def handle_cast({:add_experience, exp}, player) do
    new_exp = player.experience + exp
    new_level = calculate_level(new_exp)

    new_player = %{player | experience: new_exp, level: new_level}

    # Si level up, augmenter les stats
    new_player = if new_level > player.level do
      level_up_stats(new_player)
    else
      new_player
    end

    {:noreply, new_player}
  end

  @impl true
  def handle_call(:get_state, _from, player) do
    {:reply, player, player}
  end

  @impl true
  def handle_info(:save_player, player) do
    save_player_to_db(player)
    {:noreply, player}
  end

  # Fonctions privées
  defp save_player_to_db(player) do
    case Accounts.get_user_by_player_id(player.id) do
      nil ->
        # Créer le user en DB
        user_attrs = User.from_player_state(player)
        Accounts.create_user(user_attrs)

      user ->
        # Mettre à jour le user
        user_attrs = User.from_player_state(player)
        Accounts.update_user(user, user_attrs)
    end
  end

  defp calculate_level(experience) do
    # Formule simple: level = sqrt(exp / 100) + 1
    :math.sqrt(experience / 100) |> Float.floor() |> trunc() |> Kernel.+(1)
  end

  defp level_up_stats(player) do
    # Augmenter les stats à chaque level up
    new_stats = %{
      strength: player.stats.strength + 2,
      speed: player.stats.speed + 2,
      endurance: player.stats.endurance + 2,
      intelligence: player.stats.intelligence + 1
    }

    %{player | stats: new_stats}
  end
end
