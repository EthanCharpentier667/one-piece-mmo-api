defmodule OnePieceMmo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :player_id, :string, null: false
      add :name, :string, null: false
      add :level, :integer, default: 1
      add :experience, :integer, default: 0
      add :bounty, :integer, default: 0

      # Position fields
      add :position_x, :decimal, precision: 10, scale: 2, default: 0.0
      add :position_y, :decimal, precision: 10, scale: 2, default: 0.0
      add :position_z, :decimal, precision: 10, scale: 2, default: 0.0
      add :current_island, :string, default: "starter_island"

      # Crew fields
      add :crew_id, :string
      add :is_crew_captain, :boolean, default: false

      # Stats
      add :strength, :integer, default: 10
      add :speed, :integer, default: 10
      add :endurance, :integer, default: 10
      add :intelligence, :integer, default: 10

      # Devil Fruit
      add :devil_fruit_type, :string
      add :devil_fruit_name, :string

      # Activity tracking
      add :last_login, :utc_datetime
      add :last_position_update, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:player_id])
    create index(:users, [:crew_id])
    create index(:users, [:current_island])
    create index(:users, [:last_login])
  end
end
