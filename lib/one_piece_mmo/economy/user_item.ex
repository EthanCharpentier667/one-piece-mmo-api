defmodule OnePieceMmo.Economy.UserItem do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :player_id, :item_id, :quantity, :equipped, :durability, :enchantments]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "user_items" do
    field :player_id, :string
    field :item_id, :string
    field :quantity, :integer, default: 1
    field :equipped, :boolean, default: false
    field :durability, :integer, default: 100  # For weapons/armor
    field :enchantments, :map  # Special upgrades

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_item, attrs) do
    user_item
    |> cast(attrs, [:player_id, :item_id, :quantity, :equipped, :durability, :enchantments])
    |> validate_required([:player_id, :item_id, :quantity])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:durability, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> unique_constraint([:player_id, :item_id])
  end
end
