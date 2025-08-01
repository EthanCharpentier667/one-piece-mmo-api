defmodule OnePieceMmo.Repo.Migrations.AddBerriesToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :berries, :bigint, default: 1000  # Start with 1000 berries
    end

    create index(:users, [:berries])
  end
end
