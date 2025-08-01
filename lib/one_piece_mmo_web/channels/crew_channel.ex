defmodule OnePieceMmoWeb.CrewChannel do
  use OnePieceMmoWeb, :channel

  alias OnePieceMmo.{Player, Crew}

  @impl true
  def join("crew:" <> crew_id, _payload, socket) do
    player_id = socket.assigns.player_id

    # Vérifier que le joueur fait partie de cet équipage
    case Player.get_state(player_id) do
      %{crew_id: ^crew_id} ->
        # Envoyer les infos de l'équipage
        crew_info = Crew.get_state(crew_id)
        {:ok, %{crew: crew_info}, socket}
      _ ->
        {:error, %{reason: "Not a member of this crew"}}
    end
  end

  # Chat d'équipage
  @impl true
  def handle_in("crew_message", %{"message" => message}, socket) do
    player_id = socket.assigns.player_id
    player_name = socket.assigns.player_name

    broadcast(socket, "crew_message", %{
      player_id: player_id,
      player_name: player_name,
      message: message,
      timestamp: DateTime.utc_now()
    })

    {:reply, :ok, socket}
  end

  # Coordination d'équipage
  def handle_in("crew_coordinate", %{"action" => action, "data" => data}, socket) do
    player_id = socket.assigns.player_id

    broadcast_from(socket, "crew_coordinate", %{
      player_id: player_id,
      action: action,
      data: data
    })

    {:reply, :ok, socket}
  end
end
