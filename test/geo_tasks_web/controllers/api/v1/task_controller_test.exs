defmodule GeoTasksWeb.API.V1.TaskControllerTest do
  use GeoTasksWeb.ConnCase
  import Routes

  setup do
    driver = build(:user) |> make_driver() |> insert()
    driver_token = build(:user_token) |> assign_user(driver) |> insert() |> Map.get(:token)

    manager = build(:user) |> make_manager() |> insert()
    manager_token = build(:user_token) |> assign_user(manager) |> insert() |> Map.get(:token)

    [
      driver: driver,
      manager: manager,
      driver_conn: build_conn() |> put_req_header("authorization", "Bearer #{driver_token}"),
      manager_conn: build_conn() |> put_req_header("authorization", "Bearer #{manager_token}")
    ]
  end

  describe "create/2" do
    setup do
      [
        valid_task_attrs: %{
          "title" => "My Super Task",
          "description" => "My Super Task Description",
          "pickup_point" => %{"lat" => 40.7517, "lng" => -73.9755},
          "delivery_point" => %{"lat" => 40.7736, "lng" => -73.9836}
        }
      ]
    end

    test "should create a new Task when valid token and params provided", ctx do
      params = %{task: ctx[:valid_task_attrs]}

      conn = post(ctx[:manager_conn], api_v1_task_path(ctx[:manager_conn], :create), params)
      %{"result" => "ok", "entity" => task} = json_response(conn, :created)

      assert Map.keys(task) == ["delivery_point", "description", "id", "pickup_point", "pickup_point_distance", "state", "title"]
    end

    test "should ignore unallowable params", ctx do
      params = %{task: Map.put(ctx[:valid_task_attrs], "state", "done")}

      conn = post(ctx[:manager_conn], api_v1_task_path(ctx[:manager_conn], :create), params)
      %{"result" => "ok", "entity" => task} = json_response(conn, :created)

      assert task["state"] == "new"
    end

    test "should return bad_request when invalid params were provided", ctx do
      params = %{task: ctx[:valid_task_attrs] |> Map.delete("title")}

      conn = post(ctx[:manager_conn], api_v1_task_path(ctx[:manager_conn], :create), params)
      %{"result" => "error", "errors" => errors} = json_response(conn, :bad_request)

      assert errors == ["title is missing"]
    end

    test "should return bad_request when Task params where not nested into 'task'", ctx do
      params = ctx[:valid_task_attrs]

      conn = post(ctx[:manager_conn], api_v1_task_path(ctx[:manager_conn], :create), params)
      %{"result" => "error", "errors" => errors} = json_response(conn, :bad_request)

      assert errors == ["Param 'task' must be provided"]
    end

    test "should return unauthorized if driver token was provided", ctx do
      params = %{task: ctx[:valid_task_attrs]}

      conn = post(ctx[:driver_conn], api_v1_task_path(ctx[:driver_conn], :create), params)
      %{"result" => "error", "errors" => errors} = json_response(conn, :unauthorized)

      assert errors == ["You're not authorized to use this resource"]
    end
  end

  describe "index/2" do
    setup ctx do
      build(:task, %{manager_id: ctx[:manager].id, pickup_point: geo_empire_state()}) |> insert()
      build(:task, %{manager_id: ctx[:manager].id, pickup_point: geo_linkoln_center()}) |> insert()

      [
        point_params: %{"lat" => "40.75179106834696", "lng" => "-73.97550478842338"}
      ]
    end

    test "should return a list of tasks for a given point when valid token provided", ctx do
      params = ctx[:point_params]
      conn = get(ctx[:driver_conn], api_v1_task_path(ctx[:driver_conn], :index, params))
      %{"tasks" => tasks, "result" => "ok"} = json_response(conn, :ok)

      assert length(tasks) == 2
    end

    test "should return only one task when tasks_limit was provided", ctx do
      params = ctx[:point_params] |> Map.merge(%{"tasks_limit" => 1})
      conn = get(ctx[:driver_conn], api_v1_task_path(ctx[:driver_conn], :index, params))
      %{"tasks" => tasks, "result" => "ok"} = json_response(conn, :ok)

      assert length(tasks) == 1
    end

    test "should return only one task when distance_limit was provided", ctx do
      params = ctx[:point_params] |> Map.merge(%{"distance_limit" => 1100})
      conn = get(ctx[:driver_conn], api_v1_task_path(ctx[:driver_conn], :index, params))
      %{"tasks" => tasks, "result" => "ok"} = json_response(conn, :ok)

      assert length(tasks) == 1
    end

    test "should return bad_request if lat/lng params were not provided", ctx do
      params = %{}
      conn = get(ctx[:driver_conn], api_v1_task_path(ctx[:driver_conn], :index, params))
      %{"errors" => errors, "result" => "error"} = json_response(conn, :bad_request)

      assert errors == ["Params 'lat' and 'lng' must be provided"]
    end

    test "should return unauthorized if manager token was provided", ctx do
      params = ctx[:point_params]
      conn = get(ctx[:manager_conn], api_v1_task_path(ctx[:manager_conn], :index, params))
      %{"errors" => errors, "result" => "error"} = json_response(conn, :unauthorized)

      assert errors == ["You're not authorized to use this resource"]
    end
  end

  describe "pick/2" do
    setup ctx do
      new_task = build(:task, %{
        manager_id: ctx[:manager].id,
        pickup_point: geo_empire_state()
      }) |> insert()

      [
        task_id: new_task.id
      ]
    end

    test "should change Task state when valid token and params provided", ctx do
      conn = put(ctx[:driver_conn], api_v1_task_pick_path(ctx[:driver_conn], :pick, ctx[:task_id]))
      %{"result" => "ok", "entity" => task} = json_response(conn, :ok)

      assert task["state"] == "assigned"
    end

    test "should return an error when Task was not found", ctx do
      conn = put(ctx[:driver_conn], api_v1_task_pick_path(ctx[:driver_conn], :pick, Ecto.UUID.generate()))
      %{"result" => "error", "errors" => errors} = json_response(conn, :bad_request)

      assert errors == ["Task not found"]
    end

    test "should return unauthorized if manager token was provided", ctx do
      conn = put(ctx[:manager_conn], api_v1_task_pick_path(ctx[:manager_conn], :pick, ctx[:task_id]))
      %{"errors" => errors, "result" => "error"} = json_response(conn, :unauthorized)

      assert errors == ["You're not authorized to use this resource"]
    end
  end

  describe "finish/2" do
    setup ctx do
      assigned_task = build(:task, %{
        manager_id: ctx[:manager].id,
        driver_id: ctx[:driver].id,
        state: "assigned",
        pickup_point: geo_empire_state()
      }) |> insert()

      [
        task_id: assigned_task.id
      ]
    end

    test "should change Task state when valid token and params provided", ctx do
      conn = put(ctx[:driver_conn], api_v1_task_finish_path(ctx[:driver_conn], :finish, ctx[:task_id]))
      %{"result" => "ok", "entity" => task} = json_response(conn, :ok)

      assert task["state"] == "done"
    end

    test "should return an error when Task was not found", ctx do
      conn = put(ctx[:driver_conn], api_v1_task_finish_path(ctx[:driver_conn], :finish, Ecto.UUID.generate()))
      %{"result" => "error", "errors" => errors} = json_response(conn, :bad_request)

      assert errors == ["Task not found"]
    end

    test "should return unauthorized if manager token was provided", ctx do
      conn = put(ctx[:manager_conn], api_v1_task_finish_path(ctx[:manager_conn], :finish, ctx[:task_id]))
      %{"errors" => errors, "result" => "error"} = json_response(conn, :unauthorized)

      assert errors == ["You're not authorized to use this resource"]
    end
  end
end

