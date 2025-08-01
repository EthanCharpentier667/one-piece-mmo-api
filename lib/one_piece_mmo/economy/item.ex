defmodule OnePieceMmo.Economy.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:item_id, :name, :description, :type, :rarity, :value, :stats_bonus, :consumable_effect, :requirements, :max_stack, :tradeable, :sellable]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "items" do
    field :item_id, :string
    field :name, :string
    field :description, :string
    field :type, :string  # weapon, armor, consumable, treasure, devil_fruit
    field :rarity, :string  # common, uncommon, rare, epic, legendary, mythical
    field :value, :integer  # Price in berries
    field :stats_bonus, :map  # %{strength: 5, speed: 2}
    field :consumable_effect, :map  # %{health: 100, mana: 50}
    field :requirements, :map  # %{level: 10, devil_fruit: false}
    field :max_stack, :integer, default: 1
    field :tradeable, :boolean, default: true
    field :sellable, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :item_id, :name, :description, :type, :rarity, :value,
      :stats_bonus, :consumable_effect, :requirements, :max_stack,
      :tradeable, :sellable
    ])
    |> validate_required([:item_id, :name, :type, :rarity, :value])
    |> unique_constraint(:item_id)
    |> validate_inclusion(:type, ["weapon", "armor", "consumable", "treasure", "devil_fruit", "misc"])
    |> validate_inclusion(:rarity, ["common", "uncommon", "rare", "epic", "legendary", "mythical"])
    |> validate_number(:value, greater_than: 0)
    |> validate_number(:max_stack, greater_than: 0)
  end
end
