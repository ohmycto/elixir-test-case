defmodule GeoTasks.TaskManager do
  import Ecto.Query
  import Geo.PostGIS
  alias GeoTasks.{Repo, Task, TaskStateMachine, User}

  @type user() :: %User{id: String.t()}
  @type task() :: %Task{}
  @type geo_point() :: %Geo.Point{coordinates: {float(), float()}}
  @type changeset() :: %Ecto.Changeset{errors: Keyword.t()}

  @default_distance_limit 3_000 # in meters
  @default_tasks_limit 3

  @spec create(map(), user()) :: {:ok, task()} | {:error, changeset()}
  def create(attrs, %User{id: manager_id, role: :manager}) do
    task_attrs = prepare_attrs(attrs)

    %Task{manager_id: manager_id}
    |> Task.manager_changeset(task_attrs)
    |> Repo.insert()
  end

  defp prepare_attrs(%{"pickup_point" => pp, "delivery_point" => dp} = attrs) do
    attrs
    |> Map.put("pickup_point", point_param_to_geo_json(pp))
    |> Map.put("delivery_point", point_param_to_geo_json(dp))
  end

  defp point_param_to_geo_json(%{"lat" => lat, "lng" => lng}) do
    %Geo.Point{coordinates: {lat, lng}, srid: 4326}
  end

  @spec find_nearby(geo_point(), map()) :: list(task())
  def find_nearby(%Geo.Point{} = point, search_opts \\ %{}) do
    distance_limit = Map.get(search_opts, "distance_limit", @default_distance_limit)
    tasks_limit = Map.get(search_opts, "tasks_limit", @default_tasks_limit)

    query = from task in Task,
      where: (
        task.state == "new"
        and st_distance(task.pickup_point, ^point) <= ^distance_limit
      ),
      order_by: [asc: st_distance(task.pickup_point, ^point)],
      limit: ^tasks_limit,
      select: %{task | pickup_point_distance: st_distance(task.pickup_point, ^point)}

    query |> Repo.all()
  end

  @spec pick(task() | Ecto.UUID.t(), user()) :: {:ok, task()} | {:error, String.t()} | {:error, changeset()}
  def pick(task_id, user) when is_binary(task_id) do
    case get_by_id(task_id) do
      {:ok, task} ->
        pick(task, user)

      err ->
        err
    end
  end
  def pick(%Task{state: "new", driver_id: nil} = task, %User{id: driver_id, role: :driver}) do
    case task |> Map.put(:driver_id, driver_id) |> Machinery.transition_to(TaskStateMachine, "assigned") do
      {:ok, updated_task} ->
        task
        |> Task.driver_changeset(Map.take(updated_task, [:state, :driver_id]))
        |> Repo.update()

      err ->
        err
    end
  end
  def pick(_, _) do
    {:error, "Can't assign Task in current state"}
  end

  @spec finish(task() | Ecto.UUID.t(), user()) :: {:ok, task()} | {:error, String.t()}
  def finish(task_id, user) when is_binary(task_id) do
    case get_by_id(task_id) do
      {:ok, task} ->
        finish(task, user)

      err ->
        err
    end
  end
  def finish(
    %Task{state: "assigned", driver_id: assigned_driver_id} = task,
    %User{id: driver_id, role: :driver}) when assigned_driver_id == driver_id do

    case task |> Machinery.transition_to(TaskStateMachine, "done") do
      {:ok, updated_task} ->
        task
        |> Task.driver_changeset(Map.take(updated_task, [:state]))
        |> Repo.update()

      err ->
        err
    end
  end
  def finish(_, _) do
    {:error, "Bad Task state or Task assigned to another user"}
  end

  @spec get_by_id(Ecto.UUID.t()) :: {:ok, task()} | {:error, String.t()}
  def get_by_id(task_id) do
    case Repo.get(Task, task_id) do
      nil ->
        {:error, "Task not found"}

      task
        -> {:ok, task}
    end
  end
end