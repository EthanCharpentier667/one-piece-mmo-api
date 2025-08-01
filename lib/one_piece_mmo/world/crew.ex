defmodule OnePieceMmo.World.Crew do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "crews" do
    field :crew_id, :string
    field :name, :string
    field :captain_id, :string
    field :members, {:array, :string}, default: []
    field :total_bounty, :integer, default: 0
    field :reputation, :integer, default: 0
    field :max_members, :integer, default: 10
    field :description, :string
    field :flag_symbol, :string
    field :territory, :string

    # Crew stats and achievements
    field :battles_won, :integer, default: 0
    field :battles_lost, :integer, default: 0
    field :islands_visited, {:array, :string}, default: []
    field :treasures_found, :integer, default: 0

    # Activity tracking
    field :last_activity, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(crew, attrs) do
    crew
    |> cast(attrs, [
      :crew_id, :name, :captain_id, :members, :total_bounty, :reputation,
      :max_members, :description, :flag_symbol, :territory,
      :battles_won, :battles_lost, :islands_visited, :treasures_found,
      :last_activity
    ])
    |> validate_required([:crew_id, :name, :captain_id])
    |> unique_constraint(:crew_id)
    |> validate_length(:name, min: 3, max: 50)
    |> validate_number(:max_members, greater_than: 0, less_than_or_equal_to: 50)
    |> validate_number(:total_bounty, greater_than_or_equal_to: 0)
    |> validate_number(:reputation, greater_than_or_equal_to: 0)
  end

  @doc """
  Convert crew to GenServer format
  """
  def to_crew_state(%__MODULE__{} = crew) do
    %OnePieceMmo.Crew{
      id: crew.crew_id,
      name: crew.name,
      captain_id: crew.captain_id,
      members: crew.members || [],
      total_bounty: crew.total_bounty,
      reputation: crew.reputation,
      max_members: crew.max_members
    }
  end

  @doc """
  Convert crew state to database attributes
  """
  def from_crew_state(%OnePieceMmo.Crew{} = crew_state) do
    %{
      crew_id: crew_state.id,
      name: crew_state.name,
      captain_id: crew_state.captain_id,
      members: crew_state.members,
      total_bounty: crew_state.total_bounty,
      reputation: crew_state.reputation,
      max_members: crew_state.max_members,
      last_activity: DateTime.utc_now()
    }
  end

  @doc """
  Check if crew is at member capacity
  """
  def at_capacity?(%__MODULE__{} = crew) do
    member_count = length(crew.members || [])
    member_count >= crew.max_members
  end

  @doc """
  Check if player is crew captain
  """
  def is_captain?(%__MODULE__{} = crew, player_id) do
    crew.captain_id == player_id
  end

  @doc """
  Check if player is crew member
  """
  def is_member?(%__MODULE__{} = crew, player_id) do
    player_id in (crew.members || [])
  end
end
