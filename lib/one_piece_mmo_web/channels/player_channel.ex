defmodule OnePieceMmoWeb.PlayerChannel do
  use OnePieceMmoWeb, :channel

  alias OnePieceMmo.Player

  @impl true
  def join("player:" <> player_id, _payload, socket) do
    if socket.assigns.player_id == player_id do
      {:ok, socket}
    else
      {:error, %{reason: "Unauthorized"}}
    end
  end

  @impl true
  def handle_in("update_stats", %{"experience" => exp}, socket) do
    player_id = socket.assigns.player_id

    Player.add_experience(player_id, exp)
    player_state = Player.get_state(player_id)

    push(socket, "stats_updated", %{
      level: player_state.level,
      experience: player_state.experience,
      stats: player_state.stats
    })

    {:reply, :ok, socket}
  end

  def handle_in("private_action", %{"action" => action, "data" => data}, socket) do
    player_id = socket.assigns.player_id

    # Traiter l'action privée (combat, quête, etc.)
    result = handle_private_action(action, data, player_id)

    {:reply, {:ok, result}, socket}
  end

  defp handle_private_action("quest_complete", %{"quest_id" => quest_id}, player_id) do
    # Logique de completion de quête
    Player.add_experience(player_id, 100)
    %{message: "Quest #{quest_id} completed!", experience_gained: 100}
  end

  defp handle_private_action("battle_result", %{"won" => won, "enemy" => enemy}, player_id) do
    if won do
      Player.add_experience(player_id, 50)
      %{message: "Victory against #{enemy}!", experience_gained: 50}
    else
      %{message: "Defeated by #{enemy}..."}
    end
  end

  defp handle_private_action(_action, _data, _player_id) do
    %{error: "Unknown action"}
  end
end
