defmodule OnePieceMmoWeb.UserSocket do
  use Phoenix.Socket

  # Channels
  channel "world:*", OnePieceMmoWeb.WorldChannel
  channel "crew:*", OnePieceMmoWeb.CrewChannel
  channel "player:*", OnePieceMmoWeb.PlayerChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"player_id" => player_id, "player_name" => player_name}, socket, _connect_info) do
    socket = socket
    |> assign(:player_id, player_id)
    |> assign(:player_name, player_name)

    {:ok, socket}
  end

  # Fallback pour connexions sans paramètres (pour debug)
  def connect(params, socket, _connect_info) do
    player_id = Map.get(params, "player_id", "anonymous_#{:rand.uniform(1000)}")
    player_name = Map.get(params, "player_name", "Anonymous Player")

    socket = socket
    |> assign(:player_id, player_id)
    |> assign(:player_name, player_name)

    {:ok, socket}
  end  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     OnePieceMmoWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.player_id}"
end
