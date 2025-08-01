defmodule OnePieceMmo.World do
  @moduledoc """
  The World context for crews and world-related data.
  """

  import Ecto.Query, warn: false
  alias OnePieceMmo.Repo
  alias OnePieceMmo.World.Crew

  @doc """
  Returns the list of crews.
  """
  def list_crews do
    Repo.all(Crew)
  end

  @doc """
  Gets a single crew.
  """
  def get_crew!(id), do: Repo.get!(Crew, id)

  @doc """
  Gets a crew by crew_id.
  """
  def get_crew_by_crew_id(crew_id) do
    Repo.get_by(Crew, crew_id: crew_id)
  end

  @doc """
  Creates a crew.
  """
  def create_crew(attrs \\ %{}) do
    %Crew{}
    |> Crew.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a crew.
  """
  def update_crew(%Crew{} = crew, attrs) do
    crew
    |> Crew.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a crew.
  """
  def delete_crew(%Crew{} = crew) do
    Repo.delete(crew)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking crew changes.
  """
  def change_crew(%Crew{} = crew, attrs \\ %{}) do
    Crew.changeset(crew, attrs)
  end

  @doc """
  Creates or updates a crew based on crew_id.
  """
  def upsert_crew(attrs) do
    case get_crew_by_crew_id(attrs.crew_id || attrs["crew_id"]) do
      nil -> create_crew(attrs)
      crew -> update_crew(crew, attrs)
    end
  end

  @doc """
  Add a member to a crew.
  """
  def add_crew_member(crew_id, player_id) do
    case get_crew_by_crew_id(crew_id) do
      nil -> {:error, :crew_not_found}
      crew ->
        members = crew.members || []
        if player_id in members do
          {:error, :already_member}
        else
          update_crew(crew, %{members: [player_id | members]})
        end
    end
  end

  @doc """
  Remove a member from a crew.
  """
  def remove_crew_member(crew_id, player_id) do
    case get_crew_by_crew_id(crew_id) do
      nil -> {:error, :crew_not_found}
      crew ->
        members = (crew.members || []) |> List.delete(player_id)
        update_crew(crew, %{members: members})
    end
  end

  @doc """
  Get crews with their member count.
  """
  def list_crews_with_stats do
    Crew
    |> select([c], %{
      crew_id: c.crew_id,
      name: c.name,
      captain_id: c.captain_id,
      member_count: fragment("array_length(?, 1)", c.members),
      total_bounty: c.total_bounty,
      reputation: c.reputation,
      created_at: c.inserted_at
    })
    |> Repo.all()
  end
end
