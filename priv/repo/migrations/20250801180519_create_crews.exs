defmodule OnePieceMmo.Repo.Migrations.CreateCrews do
  use Ecto.Migration

  def change do
    create table(:crews, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :crew_id, :string, null: false
      add :name, :string, null: false
      add :captain_id, :string, null: false
      add :members, {:array, :string}, default: []
      add :total_bounty, :integer, default: 0
      add :reputation, :integer, default: 0
      add :max_members, :integer, default: 10
      add :description, :text
      add :flag_symbol, :string
      add :territory, :string

      # Crew stats and achievements
      add :battles_won, :integer, default: 0
      add :battles_lost, :integer, default: 0
      add :islands_visited, {:array, :string}, default: []
      add :treasures_found, :integer, default: 0

      # Activity tracking
      add :last_activity, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:crews, [:crew_id])
    create index(:crews, [:captain_id])
    create index(:crews, [:name])
    create index(:crews, [:total_bounty])
    create index(:crews, [:last_activity])

    # Index for searching members
    create index(:crews, [:members], using: :gin)
  end
end
