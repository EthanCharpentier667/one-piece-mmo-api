defmodule OnePieceMmo.Economy.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:transaction_id, :from_player_id, :to_player_id, :amount, :transaction_type, :description, :item_id, :item_quantity, :metadata, :inserted_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "transactions" do
    field :transaction_id, :string
    field :from_player_id, :string  # nil for shop purchases
    field :to_player_id, :string    # nil for shop sales
    field :amount, :integer
    field :transaction_type, :string  # transfer, purchase, sale, quest_reward, battle_reward
    field :description, :string
    field :item_id, :string  # If transaction involves an item
    field :item_quantity, :integer  # Quantity of item involved
    field :metadata, :map  # Additional data

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :transaction_id, :from_player_id, :to_player_id, :amount,
      :transaction_type, :description, :item_id, :item_quantity, :metadata
    ])
    |> validate_required([:amount, :transaction_type])
    |> validate_number(:amount, greater_than: 0)
    |> validate_inclusion(:transaction_type, [
      "transfer", "purchase", "sale", "quest_reward", "battle_reward",
      "daily_login", "crew_share", "bounty_claim"
    ])
    |> put_transaction_id()
  end

  defp put_transaction_id(changeset) do
    case get_field(changeset, :transaction_id) do
      nil ->
        transaction_id = "txn_" <> (:crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower))
        put_change(changeset, :transaction_id, transaction_id)
      _ ->
        changeset
    end
  end
end
