defmodule OnePieceMmo.Crew do
  use GenServer

  alias OnePieceMmo.World
  alias OnePieceMmo.World.Crew, as: CrewSchema

  defstruct [
    :id,
    :name,
    :captain_id,
    :members,
    :created_at,
    :total_bounty,
    :reputation,
    :max_members
  ]

  # API Publique
  def create_crew(crew_name, captain_id) do
    crew_id = generate_crew_id()

    case DynamicSupervisor.start_child(
      OnePieceMmo.CrewSupervisor,
      {__MODULE__, {crew_id, crew_name, captain_id}}
    ) do
      {:ok, _pid} -> {:ok, crew_id}
      error -> error
    end
  end

  def start_link({crew_id, crew_name, captain_id}) do
    GenServer.start_link(__MODULE__, {crew_id, crew_name, captain_id}, name: via_tuple(crew_id))
  end

  def add_member(crew_id, player_id) do
    GenServer.call(via_tuple(crew_id), {:add_member, player_id})
  end

  def remove_member(crew_id, player_id) do
    GenServer.call(via_tuple(crew_id), {:remove_member, player_id})
  end

  def get_state(crew_id) do
    case GenServer.whereis(via_tuple(crew_id)) do
      nil -> nil
      _pid -> GenServer.call(via_tuple(crew_id), :get_state)
    end
  end

  def update_bounty(crew_id, new_bounty) do
    GenServer.cast(via_tuple(crew_id), {:update_bounty, new_bounty})
  end

  # Registry
  defp via_tuple(crew_id) do
    {:via, Registry, {OnePieceMmo.CrewRegistry, crew_id}}
  end

  defp generate_crew_id do
    "crew_" <> (:crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower))
  end

  # Callbacks GenServer
  @impl true
  def init({crew_id, crew_name, captain_id}) do
    crew = load_or_create_crew(crew_id, crew_name, captain_id)

    # Programmer des sauvegardes périodiques (toutes les 60 secondes)
    :timer.send_interval(60_000, :save_crew)

    {:ok, crew}
  end

  # Charger l'équipage depuis la DB ou en créer un nouveau
  defp load_or_create_crew(crew_id, crew_name, captain_id) do
    case World.get_crew_by_crew_id(crew_id) do
      nil ->
        # Créer un nouvel équipage
        crew = create_new_crew(crew_id, crew_name, captain_id)

        # Sauvegarder en DB
        crew_attrs = CrewSchema.from_crew_state(crew)
        World.create_crew(crew_attrs)

        crew

      crew_schema ->
        # Charger depuis la DB
        CrewSchema.to_crew_state(crew_schema)
    end
  end

  defp create_new_crew(crew_id, crew_name, captain_id) do
    %__MODULE__{
      id: crew_id,
      name: crew_name,
      captain_id: captain_id,
      members: [captain_id],
      created_at: DateTime.utc_now(),
      total_bounty: 0,
      reputation: 0,
      max_members: 10
    }
  end

  @impl true
  def handle_call({:add_member, player_id}, _from, crew) do
    if length(crew.members) >= crew.max_members do
      {:reply, {:error, "Crew is full"}, crew}
    else
      new_members = [player_id | crew.members]
      new_crew = %{crew | members: new_members}
      {:reply, :ok, new_crew}
    end
  end

  @impl true
  def handle_call({:remove_member, player_id}, _from, crew) do
    new_members = List.delete(crew.members, player_id)

    # Si le capitaine quitte, dissoudre l'équipage ou nommer un nouveau capitaine
    new_crew = if player_id == crew.captain_id do
      case new_members do
        [] ->
          # Équipage vide, on peut l'arrêter
          {:stop, :normal, :ok, crew}
        [new_captain | _] ->
          %{crew | captain_id: new_captain, members: new_members}
      end
    else
      %{crew | members: new_members}
    end

    case new_crew do
      {:stop, :normal, :ok, crew} -> {:stop, :normal, :ok, crew}
      updated_crew -> {:reply, :ok, updated_crew}
    end
  end

  @impl true
  def handle_call(:get_state, _from, crew) do
    {:reply, crew, crew}
  end

  @impl true
  def handle_cast({:update_bounty, new_bounty}, crew) do
    new_crew = %{crew | total_bounty: new_bounty}
    {:noreply, new_crew}
  end

  @impl true
  def handle_info(:save_crew, crew) do
    save_crew_to_db(crew)
    {:noreply, crew}
  end

  # Fonctions privées
  defp save_crew_to_db(crew) do
    case World.get_crew_by_crew_id(crew.id) do
      nil ->
        # Créer l'équipage en DB
        crew_attrs = CrewSchema.from_crew_state(crew)
        World.create_crew(crew_attrs)

      crew_schema ->
        # Mettre à jour l'équipage
        crew_attrs = CrewSchema.from_crew_state(crew)
        World.update_crew(crew_schema, crew_attrs)
    end
  end
end
