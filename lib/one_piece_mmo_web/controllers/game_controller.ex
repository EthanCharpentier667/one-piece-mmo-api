defmodule OnePieceMmoWeb.GameController do
  use OnePieceMmoWeb, :controller
  alias OnePieceMmoWeb.Presence
  alias OnePieceMmo.Accounts
  alias OnePieceMmo.World

  def status(conn, _params) do
    json(conn, %{
      status: "online",
      server: "One Piece MMO",
      version: "1.0.0",
      players_online: get_players_online_count(),
      timestamp: DateTime.utc_now()
    })
  end

  def world_info(conn, _params) do
    json(conn, %{
      world: "Grand Line",
      islands: [
        %{name: "Starter Island", position: %{x: 0, y: 0}},
        %{name: "Loguetown", position: %{x: 100, y: 0}},
        %{name: "Whiskey Peak", position: %{x: 200, y: 50}},
        %{name: "Little Garden", position: %{x: 300, y: 100}}
      ],
      weather: "Sunny",
      sea_level: "Calm"
    })
  end

  def online_players(conn, _params) do
    # Récupérer les joueurs en ligne via Presence
    presence_data = Presence.list("world:grand_line")

    players = Enum.map(presence_data, fn {player_id, %{metas: [meta | _]}} ->
      %{
        id: player_id,
        name: meta.name,
        level: meta.level,
        position: meta.position,
        bounty: meta.bounty,
        crew_id: meta.crew_id,
        online_at: meta.online_at
      }
    end)

    json(conn, %{
      count: length(players),
      players: players
    })
  end

  def player_stats(conn, %{"player_id" => player_id}) do
    case Accounts.get_user_by_player_id(player_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Player not found"})

      user ->
        json(conn, %{
          player: %{
            id: user.player_id,
            name: user.name,
            level: user.level,
            experience: user.experience,
            bounty: user.bounty,
            position: %{
              x: user.position_x,
              y: user.position_y,
              z: user.position_z,
              island: user.current_island
            },
            crew_id: user.crew_id,
            is_crew_captain: user.is_crew_captain,
            stats: %{
              strength: user.strength,
              speed: user.speed,
              endurance: user.endurance,
              intelligence: user.intelligence
            },
            devil_fruit: if(user.devil_fruit_type, do: %{
              type: user.devil_fruit_type,
              name: user.devil_fruit_name
            }),
            last_login: user.last_login,
            created_at: user.inserted_at
          }
        })
    end
  end

  def crew_info(conn, %{"crew_id" => crew_id}) do
    case World.get_crew_by_crew_id(crew_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Crew not found"})

      crew ->
        # Obtenir les informations des membres
        members = Enum.map(crew.members || [], fn member_id ->
          case Accounts.get_user_by_player_id(member_id) do
            nil -> %{id: member_id, name: "Unknown", level: 0, bounty: 0}
            user -> %{
              id: user.player_id,
              name: user.name,
              level: user.level,
              bounty: user.bounty,
              is_captain: user.player_id == crew.captain_id
            }
          end
        end)

        json(conn, %{
          crew: %{
            id: crew.crew_id,
            name: crew.name,
            captain_id: crew.captain_id,
            members: members,
            member_count: length(crew.members || []),
            max_members: crew.max_members,
            total_bounty: crew.total_bounty,
            reputation: crew.reputation,
            description: crew.description,
            flag_symbol: crew.flag_symbol,
            territory: crew.territory,
            battles_won: crew.battles_won,
            battles_lost: crew.battles_lost,
            islands_visited: crew.islands_visited,
            treasures_found: crew.treasures_found,
            last_activity: crew.last_activity,
            created_at: crew.inserted_at
          }
        })
    end
  end

  def leaderboard(conn, _params) do
    # Top joueurs par bounty
    top_players = Accounts.list_users()
    |> Enum.sort_by(& &1.bounty, :desc)
    |> Enum.take(20)
    |> Enum.with_index(1)
    |> Enum.map(fn {user, rank} ->
      %{
        rank: rank,
        id: user.player_id,
        name: user.name,
        level: user.level,
        bounty: user.bounty,
        crew_id: user.crew_id
      }
    end)

    # Top crews par total bounty
    top_crews = World.list_crews_with_stats()
    |> Enum.sort_by(& &1.total_bounty, :desc)
    |> Enum.take(10)
    |> Enum.with_index(1)
    |> Enum.map(fn {crew, rank} ->
      %{
        rank: rank,
        id: crew.crew_id,
        name: crew.name,
        captain_id: crew.captain_id,
        member_count: crew.member_count || 0,
        total_bounty: crew.total_bounty
      }
    end)

    json(conn, %{
      top_players: top_players,
      top_crews: top_crews,
      updated_at: DateTime.utc_now()
    })
  end

  def all_crews(conn, _params) do
    crews = World.list_crews_with_stats()
    |> Enum.map(fn crew ->
      %{
        id: crew.crew_id,
        name: crew.name,
        captain_id: crew.captain_id,
        member_count: crew.member_count || 0,
        total_bounty: crew.total_bounty,
        reputation: crew.reputation,
        created_at: crew.created_at
      }
    end)

    json(conn, %{
      count: length(crews),
      crews: crews
    })
  end

  defp get_players_online_count do
    # Compter les joueurs en ligne via Presence
    "world:grand_line"
    |> Presence.list()
    |> map_size()
  end
end
