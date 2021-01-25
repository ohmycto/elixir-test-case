defmodule GeoTasks.TaskManagerTest do
  use GeoTasks.DataCase
  alias GeoTasks.TaskManager

  setup do
    manager = build(:user) |> make_manager() |> insert()
    driver = build(:user) |> make_driver() |> insert()

    [
      manager: manager,
      driver: driver,
      new_task: build(:task, %{manager_id: manager.id, pickup_point: geo_empire_state()}),
      assigned_task: build(:task, %{manager_id: manager.id, driver_id: driver.id, pickup_point: geo_empire_state(), state: "assigned"})
    ]
  end

  describe "#create/2" do
    setup do
      [
        task_attrs: %{
          "title" => "My task",
          "description" => "Task description",
          "pickup_point" => %{"lat" => 40.75010051199758, "lng" => -73.98571864017009},
          "delivery_point" => %{"lat" => 40.75814756178693, "lng" => -73.98555802324617}
        }
      ]
    end

    test "should create a new Task when Manager struct given", ctx do
      {:ok, task} = TaskManager.create(ctx[:task_attrs], ctx[:manager])

      assert task.title == "My task"
      assert task.description == "Task description"
      assert task.pickup_point == %Geo.Point{coordinates: {40.75010051199758, -73.98571864017009}, properties: %{}, srid: 4326}
      assert task.delivery_point == %Geo.Point{coordinates: {40.75814756178693, -73.98555802324617}, properties: %{}, srid: 4326}
      assert task.manager_id == ctx[:manager].id
    end
  end

  describe "#find_nearby/3" do
    setup ctx do
      [
        driver_position: %Geo.Point{coordinates: {40.75179106834696, -73.97550478842338}},
        task_empire_state: build(:task, %{manager_id: ctx[:manager].id, pickup_point: geo_empire_state()}),
        task_times_square: build(:task, %{manager_id: ctx[:manager].id, pickup_point: geo_times_square()}),
        task_linkoln_center: build(:task, %{manager_id: ctx[:manager].id, pickup_point: geo_linkoln_center()})
      ]
    end

    test "should return Tasks, considering given search options", ctx do
      ctx[:task_empire_state] |> insert()
      ctx[:task_times_square] |> insert()
      ctx[:task_linkoln_center] |> insert()

      # 1) With default distance limit.
      [t1, t2, t3] = TaskManager.find_nearby(ctx[:driver_position])

      assert t1.pickup_point == geo_linkoln_center()
      assert t2.pickup_point == geo_times_square()
      assert t3.pickup_point == geo_empire_state()

      # 2) Distance limit was set.
      [t1] = TaskManager.find_nearby(ctx[:driver_position], %{"distance_limit" => 1_100})

      assert t1.pickup_point == geo_linkoln_center()

      # 3) Max tasks limit was set.
      [t1] = TaskManager.find_nearby(ctx[:driver_position], %{"tasks_limit" => 1})

      assert t1.pickup_point == geo_linkoln_center()
    end

    test "should return only Tasks in 'new' state", ctx do
      ctx[:task_empire_state] |> insert()
      ctx[:task_times_square] |> insert()
      ctx[:task_linkoln_center] |> set_state("assigned") |> insert()

      [t1, t2] = TaskManager.find_nearby(ctx[:driver_position])

      assert t1.pickup_point == geo_times_square()
      assert t2.pickup_point == geo_empire_state()
    end
  end

  describe "#pick/2" do
    setup ctx do
      [
        task: ctx[:new_task] |> insert()
      ]
    end

    test "should change Task state to 'assigned' and set driver_id when task struct given", ctx do
      {:ok, assigned_task} = TaskManager.pick(ctx[:task], ctx[:driver])

      assert assigned_task.state == "assigned"
      assert assigned_task.driver_id == ctx[:driver].id
    end

    test "should change Task state to 'assigned' and set driver_id when task UUID given", ctx do
      {:ok, assigned_task} = TaskManager.pick(ctx[:task].id, ctx[:driver])

      assert assigned_task.state == "assigned"
      assert assigned_task.driver_id == ctx[:driver].id
    end

    test "should return an error when trying to pick an already assigned Task", ctx do
      assert TaskManager.pick(ctx[:task], ctx[:assigned_task]) ==
        {:error, "Can't assign Task in current state"}
    end
  end

  describe "#finish/1" do
    setup ctx do
      [
        another_driver: build(:user) |> make_driver(),
        task: ctx[:assigned_task] |> insert()
      ]
    end

    test "should change Task state to 'done' when Task struct given", ctx do
      {:ok, done_task} = TaskManager.finish(ctx[:task], ctx[:driver])

      assert done_task.state == "done"
    end

    test "should change Task state to 'done' when Task UUID given", ctx do
      {:ok, done_task} = TaskManager.finish(ctx[:task].id, ctx[:driver])

      assert done_task.state == "done"
    end

    test "should return an error when trying to finish a Task, assigned to another User", ctx do
      assert TaskManager.finish(ctx[:task], ctx[:another_driver]) ==
        {:error, "Bad Task state or Task assigned to another user"}
    end
  end
end