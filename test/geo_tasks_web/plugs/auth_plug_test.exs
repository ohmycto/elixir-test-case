defmodule GeoTasksWeb.Plugs.AuthPlugTest do
  use GeoTasksWeb.ConnCase
  alias GeoTasksWeb.Plugs.AuthPlug

  test "should return 401 if no auth header was provided" do
    conn = build_conn() |> AuthPlug.call([])
    %{"result" => "error", "errors" => errors} = json_response(conn, :unauthorized)

    assert conn.halted
    assert conn.status == 401
    assert errors == ["No auth header found"]
  end

  test "should return 401 if auth token was not found or revoked" do
    conn = build_conn() |> put_req_header("authorization", "Bearer invalid") |> AuthPlug.call([])
    %{"result" => "error", "errors" => errors} = json_response(conn, :unauthorized)

    assert conn.halted
    assert conn.status == 401
    assert errors == ["Token not found or revoked."]
  end

  test "should assign current_user if valid auth header was provided" do
    manager = build(:user) |> make_manager() |> insert()
    manager_token = build(:user_token) |> assign_user(manager) |> insert() |> Map.get(:token)

    conn = build_conn() |> put_req_header("authorization", "Bearer #{manager_token}") |> AuthPlug.call([])

    refute conn.halted
    assert conn.assigns.current_user == manager
  end
end