# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias OnePieceMmo.Accounts
alias OnePieceMmo.World

# Créer des utilisateurs de test
users = [
  %{
    player_id: "luffy_001",
    name: "Monkey D. Luffy",
    level: 25,
    experience: 62500,
    bounty: 1_500_000_000,
    position_x: 100.0,
    position_y: 50.0,
    position_z: 0.0,
    current_island: "whole_cake_island",
    strength: 95,
    speed: 88,
    endurance: 92,
    intelligence: 35,
    devil_fruit_type: "Paramecia",
    devil_fruit_name: "Gomu Gomu no Mi",
    last_login: DateTime.utc_now()
  },
  %{
    player_id: "zoro_002",
    name: "Roronoa Zoro",
    level: 24,
    experience: 57600,
    bounty: 1_111_000_000,
    position_x: 105.0,
    position_y: 52.0,
    position_z: 0.0,
    current_island: "whole_cake_island",
    strength: 98,
    speed: 85,
    endurance: 95,
    intelligence: 45,
    last_login: DateTime.utc_now()
  },
  %{
    player_id: "nami_003",
    name: "Nami",
    level: 20,
    experience: 40000,
    bounty: 366_000_000,
    position_x: 98.0,
    position_y: 48.0,
    position_z: 0.0,
    current_island: "whole_cake_island",
    strength: 45,
    speed: 75,
    endurance: 65,
    intelligence: 95,
    last_login: DateTime.utc_now()
  },
  %{
    player_id: "law_004",
    name: "Trafalgar D. Water Law",
    level: 26,
    experience: 67600,
    bounty: 3_000_000_000,
    position_x: 300.0,
    position_y: 100.0,
    position_z: 0.0,
    current_island: "dressrosa",
    strength: 85,
    speed: 90,
    endurance: 88,
    intelligence: 95,
    devil_fruit_type: "Paramecia",
    devil_fruit_name: "Ope Ope no Mi",
    last_login: DateTime.utc_now()
  },
  %{
    player_id: "kidd_005",
    name: "Eustass Captain Kid",
    level: 25,
    experience: 62500,
    bounty: 3_000_000_000,
    position_x: 250.0,
    position_y: 150.0,
    position_z: 0.0,
    current_island: "sabaody",
    strength: 92,
    speed: 80,
    endurance: 90,
    intelligence: 70,
    devil_fruit_type: "Paramecia",
    devil_fruit_name: "Jiki Jiki no Mi",
    last_login: DateTime.utc_now()
  }
]

Enum.each(users, fn user_attrs ->
  case Accounts.create_user(user_attrs) do
    {:ok, _user} -> IO.puts("✅ Created user: #{user_attrs.name}")
    {:error, changeset} -> IO.puts("❌ Failed to create user #{user_attrs.name}: #{inspect(changeset.errors)}")
  end
end)

# Créer des équipages de test
crews = [
  %{
    crew_id: "straw_hat_pirates",
    name: "Straw Hat Pirates",
    captain_id: "luffy_001",
    members: ["luffy_001", "zoro_002", "nami_003"],
    total_bounty: 2_977_000_000,
    reputation: 1000,
    max_members: 12,
    description: "A pirate crew led by Monkey D. Luffy to find the One Piece",
    flag_symbol: "Skull with Straw Hat",
    territory: "East Blue",
    battles_won: 45,
    battles_lost: 2,
    islands_visited: ["Dawn Island", "Orange Town", "Syrup Village", "Whole Cake Island"],
    treasures_found: 15,
    last_activity: DateTime.utc_now()
  },
  %{
    crew_id: "heart_pirates",
    name: "Heart Pirates",
    captain_id: "law_004",
    members: ["law_004"],
    total_bounty: 3_000_000_000,
    reputation: 850,
    max_members: 20,
    description: "Medical pirates led by the Surgeon of Death",
    flag_symbol: "Heart with crossed bones",
    territory: "North Blue",
    battles_won: 32,
    battles_lost: 8,
    islands_visited: ["Flevance", "Punk Hazard", "Dressrosa"],
    treasures_found: 8,
    last_activity: DateTime.utc_now()
  },
  %{
    crew_id: "kid_pirates",
    name: "Kid Pirates",
    captain_id: "kidd_005",
    members: ["kidd_005"],
    total_bounty: 3_000_000_000,
    reputation: 750,
    max_members: 15,
    description: "Violent pirates with magnetic powers",
    flag_symbol: "Skull with metal spikes",
    territory: "South Blue",
    battles_won: 28,
    battles_lost: 12,
    islands_visited: ["Sabaody", "Kaido's Territory"],
    treasures_found: 12,
    last_activity: DateTime.utc_now()
  }
]

Enum.each(crews, fn crew_attrs ->
  case World.create_crew(crew_attrs) do
    {:ok, _crew} -> IO.puts("✅ Created crew: #{crew_attrs.name}")
    {:error, changeset} -> IO.puts("❌ Failed to create crew #{crew_attrs.name}: #{inspect(changeset.errors)}")
  end
end)

IO.puts("\n🏴‍☠️ Database seeded with One Piece data!")
