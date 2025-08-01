defmodule OnePieceMmo.Economy do
  @moduledoc """
  The Economy context for managing berries, items, and transactions.
  """

  import Ecto.Query, warn: false
  alias OnePieceMmo.Repo
  alias OnePieceMmo.Economy.{Item, UserItem, Transaction}

  @doc """
  Returns the list of items.
  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.
  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Gets an item by item_id.
  """
  def get_item_by_item_id(item_id) do
    Repo.get_by(Item, item_id: item_id)
  end

  @doc """
  Creates an item.
  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an item.
  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets a user's inventory.
  """
  def get_user_inventory(player_id) do
    query = from ui in UserItem,
      join: i in Item, on: ui.item_id == i.item_id,
      where: ui.player_id == ^player_id,
      select: %{
        item_id: i.item_id,
        name: i.name,
        description: i.description,
        type: i.type,
        rarity: i.rarity,
        value: i.value,
        quantity: ui.quantity,
        equipped: ui.equipped
      }

    Repo.all(query)
  end

  @doc """
  Adds an item to user's inventory.
  """
  def add_item_to_user(player_id, item_id, quantity \\ 1) do
    case Repo.get_by(UserItem, player_id: player_id, item_id: item_id) do
      nil ->
        # Create new user item
        %UserItem{}
        |> UserItem.changeset(%{
          player_id: player_id,
          item_id: item_id,
          quantity: quantity
        })
        |> Repo.insert()

      user_item ->
        # Update existing quantity
        update_user_item(user_item, %{quantity: user_item.quantity + quantity})
    end
  end

  @doc """
  Updates a user item.
  """
  def update_user_item(%UserItem{} = user_item, attrs) do
    user_item
    |> UserItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Removes an item from user's inventory.
  """
  def remove_item_from_user(player_id, item_id, quantity \\ 1) do
    case Repo.get_by(UserItem, player_id: player_id, item_id: item_id) do
      nil ->
        {:error, :item_not_found}

      user_item when user_item.quantity <= quantity ->
        # Remove completely
        Repo.delete(user_item)

      user_item ->
        # Reduce quantity
        update_user_item(user_item, %{quantity: user_item.quantity - quantity})
    end
  end

  @doc """
  Creates a transaction record.
  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets user's transaction history.
  """
  def get_user_transactions(player_id) do
    Transaction
    |> where([t], t.from_player_id == ^player_id or t.to_player_id == ^player_id)
    |> order_by([t], desc: t.inserted_at)
    |> limit(50)
    |> Repo.all()
  end

  @doc """
  Transfer berries between players.
  """
  def transfer_berries(from_player_id, to_player_id, amount) when amount > 0 do
    alias OnePieceMmo.Accounts

    Repo.transaction(fn ->
      # Get both users
      from_user = Accounts.get_user_by_player_id(from_player_id)
      to_user = Accounts.get_user_by_player_id(to_player_id)

      cond do
        is_nil(from_user) ->
          Repo.rollback({:error, :from_user_not_found})

        is_nil(to_user) ->
          Repo.rollback({:error, :to_user_not_found})

        from_user.berries < amount ->
          Repo.rollback({:error, :insufficient_funds})

        true ->
          # Update balances
          {:ok, _} = Accounts.update_user(from_user, %{berries: from_user.berries - amount})
          {:ok, _} = Accounts.update_user(to_user, %{berries: to_user.berries + amount})

          # Record transaction
          {:ok, transaction} = create_transaction(%{
            from_player_id: from_player_id,
            to_player_id: to_player_id,
            amount: amount,
            transaction_type: "transfer",
            description: "Berry transfer"
          })

          transaction
      end
    end)
  end

  @doc """
  Buy an item from the shop.
  """
  def buy_item(player_id, item_id, quantity \\ 1) do
    alias OnePieceMmo.Accounts

    Repo.transaction(fn ->
      user = Accounts.get_user_by_player_id(player_id)
      item = get_item_by_item_id(item_id)

      cond do
        is_nil(user) ->
          Repo.rollback({:error, :user_not_found})

        is_nil(item) ->
          Repo.rollback({:error, :item_not_found})

        user.berries < (item.value * quantity) ->
          Repo.rollback({:error, :insufficient_funds})

        true ->
          total_cost = item.value * quantity

          # Deduct berries
          {:ok, _} = Accounts.update_user(user, %{berries: user.berries - total_cost})

          # Add item to inventory
          {:ok, _} = add_item_to_user(player_id, item_id, quantity)

          # Record transaction
          {:ok, transaction} = create_transaction(%{
            to_player_id: player_id,
            amount: total_cost,
            transaction_type: "purchase",
            description: "Bought #{quantity}x #{item.name}",
            item_id: item_id,
            item_quantity: quantity
          })

          transaction
      end
    end)
  end

  @doc """
  Sell an item to the shop.
  """
  def sell_item(player_id, item_id, quantity \\ 1) do
    alias OnePieceMmo.Accounts

    Repo.transaction(fn ->
      user = Accounts.get_user_by_player_id(player_id)
      item = get_item_by_item_id(item_id)
      user_item = Repo.get_by(UserItem, player_id: player_id, item_id: item_id)

      cond do
        is_nil(user) ->
          Repo.rollback({:error, :user_not_found})

        is_nil(item) ->
          Repo.rollback({:error, :item_not_found})

        is_nil(user_item) or user_item.quantity < quantity ->
          Repo.rollback({:error, :insufficient_items})

        true ->
          # Calculate sell price (50% of purchase price)
          sell_price = div(item.value * quantity, 2)

          # Add berries
          {:ok, _} = Accounts.update_user(user, %{berries: user.berries + sell_price})

          # Remove item from inventory
          {:ok, _} = remove_item_from_user(player_id, item_id, quantity)

          # Record transaction
          {:ok, transaction} = create_transaction(%{
            from_player_id: player_id,
            amount: sell_price,
            transaction_type: "sale",
            description: "Sold #{quantity}x #{item.name}",
            item_id: item_id,
            item_quantity: quantity
          })

          transaction
      end
    end)
  end

  @doc """
  Equips an item for a user.
  """
  def equip_user_item(player_id, item_id) do
    case get_user_item_by_player_and_item(player_id, item_id) do
      nil ->
        {:error, "Item not found in inventory"}

      user_item ->
        # First, unequip any other item of the same type
        item = get_item_by_item_id(item_id)
        if item && item.type in ["weapon", "armor"] do
          unequip_items_of_type(player_id, item.type)
        end

        # Then equip this item
        user_item
        |> UserItem.changeset(%{equipped: true})
        |> Repo.update()
    end
  end

  @doc """
  Unequips an item for a user.
  """
  def unequip_user_item(player_id, item_id) do
    case get_user_item_by_player_and_item(player_id, item_id) do
      nil ->
        {:error, "Item not found in inventory"}

      user_item ->
        user_item
        |> UserItem.changeset(%{equipped: false})
        |> Repo.update()
    end
  end

  defp unequip_items_of_type(player_id, type) do
    from(ui in UserItem,
      join: i in Item, on: ui.item_id == i.item_id,
      where: ui.player_id == ^player_id and i.type == ^type and ui.equipped == true
    )
    |> Repo.update_all(set: [equipped: false])
  end

  defp get_user_item_by_player_and_item(player_id, item_id) do
    Repo.get_by(UserItem, player_id: player_id, item_id: item_id)
  end
end
