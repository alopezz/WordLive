defmodule WordLiveWeb.WordLiveTest do
  use WordLiveWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "WordLive"
  end
end
