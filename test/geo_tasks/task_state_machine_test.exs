defmodule GeoTasks.TaskStateMachineTest do
  use GeoTasks.DataCase
  alias GeoTasks.TaskStateMachine

  describe "guard conditions" do
    setup do
      manager = build(:user) |> make_manager() |> insert()

      [
        task: build(:task, %{manager_id: manager.id, pickup_point: geo_empire_state()}) |> insert()
      ]
    end

    test "should not allow transition to 'assigned' if no driver_id was set", ctx do
      assert ctx[:task] |> Machinery.transition_to(TaskStateMachine, "assigned") == {:error, "driver_id must be set"}
    end
  end

end
