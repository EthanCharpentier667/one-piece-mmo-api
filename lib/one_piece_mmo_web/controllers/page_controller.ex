defmodule OnePieceMmoWeb.PageController do
  use OnePieceMmoWeb, :controller

  def test(conn, _params) do
    # Lire le contenu du fichier test.html
    test_html_path = Path.join(:code.priv_dir(:one_piece_mmo), "static/test.html")

    case File.read(test_html_path) do
      {:ok, content} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, content)

      {:error, _reason} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(404, "<h1>Page de test non trouvée</h1><p>Le fichier test.html n'existe pas.</p>")
    end
  end

  def debug(conn, _params) do
    # Lire le contenu du fichier debug.html
    debug_html_path = Path.join(:code.priv_dir(:one_piece_mmo), "static/debug.html")

    case File.read(debug_html_path) do
      {:ok, content} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, content)

      {:error, _reason} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(404, "<h1>Page de debug non trouvée</h1><p>Le fichier debug.html n'existe pas.</p>")
    end
  end
end
