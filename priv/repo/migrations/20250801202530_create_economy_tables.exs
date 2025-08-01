defmodule OnePieceMmo.Repo.Migrations.CreateEconomyTables do
  use Ecto.Migration

  def change do
    # Items table
    create table(:items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :item_id, :string, null: false
      add :name, :string, null: false
      add :description, :text
      add :type, :string, null: false
      add :rarity, :string, null: false
      add :value, :integer, null: false
      add :stats_bonus, :map
      add :consumable_effect, :map
      add :requirements, :map
      add :max_stack, :integer, default: 1
      add :tradeable, :boolean, default: true
      add :sellable, :boolean, default: true

      timestamps(type: :utc_datetime)
    end

    # User items table (inventory)
    create table(:user_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :player_id, :string, null: false
      add :item_id, :string, null: false
      add :quantity, :integer, default: 1
      add :equipped, :boolean, default: false
      add :durability, :integer, default: 100
      add :enchantments, :map

      timestamps(type: :utc_datetime)
    end

    # Transactions table
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :transaction_id, :string
      add :from_player_id, :string
      add :to_player_id, :string
      add :amount, :integer, null: false
      add :transaction_type, :string, null: false
      add :description, :string
      add :item_id, :string
      add :item_quantity, :integer
      add :metadata, :map

      timestamps(type: :utc_datetime)
    end

    # Indexes
    create unique_index(:items, [:item_id])
    create index(:items, [:type])
    create index(:items, [:rarity])
    create index(:items, [:value])

    create unique_index(:user_items, [:player_id, :item_id])
    create index(:user_items, [:player_id])
    create index(:user_items, [:item_id])
    create index(:user_items, [:equipped])

    create unique_index(:transactions, [:transaction_id])
    create index(:transactions, [:from_player_id])
    create index(:transactions, [:to_player_id])
    create index(:transactions, [:transaction_type])
    create index(:transactions, [:inserted_at])
  end
end
