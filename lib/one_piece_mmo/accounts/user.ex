defmodule OnePieceMmo.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :player_id, :string
    field :name, :string
    field :level, :integer, default: 1
    field :experience, :integer, default: 0
    field :bounty, :integer, default: 0
    field :position_x, :decimal, default: 0.0
    field :position_y, :decimal, default: 0.0
    field :position_z, :decimal, default: 0.0
    field :current_island, :string, default: "starter_island"
    field :crew_id, :string
    field :is_crew_captain, :boolean, default: false

    # Stats
    field :strength, :integer, default: 10
    field :speed, :integer, default: 10
    field :endurance, :integer, default: 10
    field :intelligence, :integer, default: 10

    # Devil Fruit
    field :devil_fruit_type, :string
    field :devil_fruit_name, :string

    # Timestamps
    field :last_login, :utc_datetime
    field :last_position_update, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :player_id, :name, :level, :experience, :bounty,
      :position_x, :position_y, :position_z, :current_island,
      :crew_id, :is_crew_captain,
      :strength, :speed, :endurance, :intelligence,
      :devil_fruit_type, :devil_fruit_name,
      :last_login, :last_position_update
    ])
    |> validate_required([:player_id, :name])
    |> unique_constraint(:player_id)
    |> validate_number(:level, greater_than: 0)
    |> validate_number(:experience, greater_than_or_equal_to: 0)
    |> validate_number(:bounty, greater_than_or_equal_to: 0)
    |> validate_number(:strength, greater_than: 0)
    |> validate_number(:speed, greater_than: 0)
    |> validate_number(:endurance, greater_than: 0)
    |> validate_number(:intelligence, greater_than: 0)
  end

  @doc """
  Convert user to player format for GenServer
  """
  def to_player_state(%__MODULE__{} = user) do
    %OnePieceMmo.Player{
      id: user.player_id,
      name: user.name,
      position: %{
        x: Decimal.to_float(user.position_x),
        y: Decimal.to_float(user.position_y),
        z: Decimal.to_float(user.position_z),
        island: user.current_island
      },
      level: user.level,
      experience: user.experience,
      bounty: user.bounty,
      crew_id: user.crew_id,
      stats: %{
        strength: user.strength,
        speed: user.speed,
        endurance: user.endurance,
        intelligence: user.intelligence
      },
      devil_fruit: if(user.devil_fruit_type, do: %{
        type: user.devil_fruit_type,
        name: user.devil_fruit_name
      }, else: nil),
      created_at: user.inserted_at,
      last_active: user.last_login || user.inserted_at
    }
  end

  @doc """
  Convert player state to user attributes for database
  """
  def from_player_state(%OnePieceMmo.Player{} = player) do
    %{
      player_id: player.id,
      name: player.name,
      level: player.level,
      experience: player.experience,
      bounty: player.bounty,
      position_x: Decimal.from_float(player.position.x),
      position_y: Decimal.from_float(player.position.y),
      position_z: Decimal.from_float(player.position.z),
      current_island: player.position.island,
      crew_id: player.crew_id,
      strength: player.stats.strength,
      speed: player.stats.speed,
      endurance: player.stats.endurance,
      intelligence: player.stats.intelligence,
      devil_fruit_type: if(player.devil_fruit, do: player.devil_fruit.type),
      devil_fruit_name: if(player.devil_fruit, do: player.devil_fruit.name),
      last_position_update: DateTime.utc_now()
    }
  end
end
