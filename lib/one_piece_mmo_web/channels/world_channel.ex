defmodule OnePieceMmoWeb.WorldChannel do
  use OnePieceMmoWeb, :channel

  alias OnePieceMmo.{Player, Crew}
  alias OnePieceMmoWeb.Presence

  @impl true
  def join("world:grand_line", _payload, socket) do
    player_id = socket.assigns.player_id
    player_name = socket.assigns.player_name

    # Démarrer le processus joueur
    case Player.start_player(player_id, player_name) do
      {:ok, _pid} ->
        send(self(), :after_join)
        {:ok, socket}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    player_id = socket.assigns.player_id
    player_name = socket.assigns.player_name

    # Obtenir les stats du joueur
    player_state = Player.get_state(player_id)

    # Ajouter à la présence avec les infos du joueur
    {:ok, _} = Presence.track(socket, player_id, %{
      name: player_name,
      position: player_state.position,
      level: player_state.level,
      bounty: player_state.bounty,
      crew_id: player_state.crew_id,
      online_at: inspect(System.system_time(:second))
    })

    # Envoyer la liste des joueurs en ligne
    push(socket, "presence_state", Presence.list(socket))

    # Envoyer l'état initial du joueur
    push(socket, "player_state", %{
      id: player_state.id,
      name: player_state.name,
      position: player_state.position,
      level: player_state.level,
      bounty: player_state.bounty,
      crew_id: player_state.crew_id,
      stats: player_state.stats
    })

    {:noreply, socket}
  end

  # Mouvement du joueur
  @impl true
  def handle_in("player_move", %{"position" => position}, socket) do
    player_id = socket.assigns.player_id

    # Mettre à jour la position du joueur
    Player.update_position(player_id, position)

    # Mettre à jour la présence
    Presence.update(socket, player_id, fn meta ->
      Map.put(meta, :position, position)
    end)

    # Broadcaster le mouvement aux autres joueurs
    broadcast_from(socket, "player_moved", %{
      player_id: player_id,
      position: position
    })

    {:reply, :ok, socket}
  end

  # Création d'équipage
  def handle_in("create_crew", %{"crew_name" => crew_name}, socket) do
    player_id = socket.assigns.player_id

    case Crew.create_crew(crew_name, player_id) do
      {:ok, crew_id} ->
        # Mettre à jour le joueur avec l'équipage
        Player.join_crew(player_id, crew_id)

        # Mettre à jour la présence
        Presence.update(socket, player_id, fn meta ->
          Map.put(meta, :crew_id, crew_id)
        end)

        # Broadcaster la création d'équipage
        broadcast(socket, "crew_created", %{
          crew_id: crew_id,
          crew_name: crew_name,
          captain_id: player_id
        })

        {:reply, {:ok, %{crew_id: crew_id}}, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  # Rejoindre un équipage
  def handle_in("join_crew", %{"crew_id" => crew_id}, socket) do
    player_id = socket.assigns.player_id

    case Crew.add_member(crew_id, player_id) do
      :ok ->
        Player.join_crew(player_id, crew_id)

        # Mettre à jour la présence
        Presence.update(socket, player_id, fn meta ->
          Map.put(meta, :crew_id, crew_id)
        end)

        # Informer les membres de l'équipage
        broadcast(socket, "crew_member_joined", %{
          crew_id: crew_id,
          player_id: player_id
        })

        {:reply, :ok, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  # Quitter un équipage
  def handle_in("leave_crew", _payload, socket) do
    player_id = socket.assigns.player_id

    case Player.get_state(player_id) do
      %{crew_id: nil} ->
        {:reply, {:error, %{reason: "Not in a crew"}}, socket}

      %{crew_id: crew_id} ->
        Crew.remove_member(crew_id, player_id)
        Player.leave_crew(player_id)

        # Mettre à jour la présence
        Presence.update(socket, player_id, fn meta ->
          Map.put(meta, :crew_id, nil)
        end)

        broadcast(socket, "crew_member_left", %{
          crew_id: crew_id,
          player_id: player_id
        })

        {:reply, :ok, socket}
    end
  end

  # Obtenir les infos d'un équipage
  def handle_in("get_crew_info", %{"crew_id" => crew_id}, socket) do
    case Crew.get_state(crew_id) do
      nil ->
        {:reply, {:error, %{reason: "Crew not found"}}, socket}

      crew_state ->
        {:reply, {:ok, crew_state}, socket}
    end
  end

  # Obtenir les joueurs en ligne
  def handle_in("get_online_players", _payload, socket) do
    online_players = Presence.list(socket)
    {:reply, {:ok, %{players: online_players}}, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    player_id = socket.assigns.player_id

    # Broadcaster la déconnexion
    broadcast(socket, "player_disconnected", %{player_id: player_id})
  end
end
