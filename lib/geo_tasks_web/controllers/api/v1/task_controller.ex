defmodule GeoTasksWeb.TaskController do
  use GeoTasksWeb.API.BaseController
  alias GeoTasks.{TaskManager, TaskValidator}

  def create(%{assigns: %{current_user: %{role: :manager} = manager}} = conn, %{"task" => task_attrs}) do
    task_attrs
    |> TaskValidator.validate()
    |> do_create_task(conn, task_attrs, manager)
  end
  def create(%{assigns: %{current_user: %{role: :driver}}} = conn, _), do: respond_unauthorized(conn)
  def create(conn, _), do: respond_bad_request(conn, "Param 'task' must be provided")

  def index(%{assigns: %{current_user: %{role: :driver}}} = conn, %{"lat" => _, "lng" => _} = params) do
    search_opts = params |> prepare_search_opts()
    tasks = params |> get_point() |> TaskManager.find_nearby(search_opts)
    render(conn, "index.json", %{tasks: tasks})
  end
  def index(%{assigns: %{current_user: %{role: :manager}}} = conn, _), do: respond_unauthorized(conn)
  def index(conn, _), do: respond_bad_request(conn, "Params 'lat' and 'lng' must be provided")

  def pick(%{assigns: %{current_user: %{role: :driver} = driver}} = conn, %{"task_id" => task_id}) do
    case TaskManager.pick(task_id, driver) do
      {:ok, task} -> respond_ok(conn, task)
      {:error, error} -> respond_bad_request(conn, error)
    end
  end
  def pick(%{assigns: %{current_user: %{role: :manager}}} = conn, _), do: respond_unauthorized(conn)

  def finish(%{assigns: %{current_user: %{role: :driver} = driver}} = conn, %{"task_id" => task_id}) do
    case TaskManager.finish(task_id, driver) do
      {:ok, task} -> respond_ok(conn, task)
      {:error, error} -> respond_bad_request(conn, error)
    end
  end
  def finish(%{assigns: %{current_user: %{role: :manager}}} = conn, _), do: respond_unauthorized(conn)


  defp do_create_task(:ok, conn, task_attrs, manager) do
    case TaskManager.create(task_attrs, manager) do
      {:ok, task} -> respond_created(conn, task)
      {:error, error} -> respond_bad_request(conn, error)
    end
  end
  defp do_create_task({:error, validation_error}, conn, _, _), do: respond_bad_request(conn, validation_error)

  defp get_point(%{"lat" => lat, "lng" => lng}), do: %Geo.Point{coordinates: {lat, lng}}

  defp prepare_search_opts(params) do
    params
    |> Map.take(["distance_limit", "tasks_limit"])
    |> Enum.into(%{}, fn({k, v}) ->
      {int_val, ""} = Integer.parse(v)
      {k, int_val}
    end)
  end
end