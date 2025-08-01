defmodule OnePieceMmo.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias OnePieceMmo.Repo
  alias OnePieceMmo.Accounts.User

  @doc """
  Returns the list of users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a user by player_id.
  """
  def get_user_by_player_id(player_id) do
    Repo.get_by(User, player_id: player_id)
  end

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Creates or updates a user based on player_id.
  """
  def upsert_user(attrs) do
    case get_user_by_player_id(attrs.player_id || attrs["player_id"]) do
      nil -> create_user(attrs)
      user -> update_user(user, attrs)
    end
  end
end
