defmodule GeoTasksWeb.Plugs.AuthPlug do
  import Plug.Conn
  alias GeoTasks.Auth.User

  @behaviour Plug

  @spec init(opts :: Keyword.t()) :: Keyword.t()
  def init(opts \\ []), do: opts

  @spec call(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def call(conn, _opts) do
    conn
    |> fetch_auth_token()
    |> assign_user()
  end

  defp fetch_auth_token(conn) do
    case get_req_header(conn, "authorization") do
      [val | _] ->
        conn |> assign(:user_token, String.replace(val, ~r/Bearer.*?\s+/, ""))

      _ ->
        conn |> respond_unauthorized("No auth header found")
    end
  end

  defp assign_user(%{halted: false, assigns: %{user_token: token}} = conn) do
    case User.authenticate_by_token(token) do
      {:error, reason} ->
        conn |> respond_unauthorized(reason)

      user ->
        conn |> assign(:current_user, user)
    end
  end
  defp assign_user(%{halted: true} = conn), do: conn

  defp respond_unauthorized(conn, reason) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(:unauthorized)
    |> Phoenix.Controller.json(%{result: "error", errors: [reason]})
    |> halt()
  end
end