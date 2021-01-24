defmodule GeoTasks.TaskTest do
  use GeoTasks.DataCase
  alias GeoTasks.Task

  setup do
    user = build(:user)

    [
      manager: user,
      manager_attrs: %{
        title: "My task",
        description: "Task description",
        pickup_point: geo_empire_state(),
        delivery_point: geo_times_square(),
        manager_id: user.id
      },
      driver_attrs: %{
        state: "assigned",
        driver_id: user.id
      }
    ]
  end

  describe "#manager_changeset/2" do
    test "should be valid with manager-owned columns", ctx do
      changeset = %Task{} |> Task.manager_changeset(ctx[:manager_attrs])

      assert changeset.valid?
    end

    test "should not cast driver-owned columns", ctx do
      attrs = ctx[:manager_attrs] |> Map.merge(ctx[:driver_attrs])
      changeset = %Task{} |> Task.manager_changeset(attrs)
      changes = changeset.changes

      refute Map.has_key?(changes, :state)
      refute Map.has_key?(changes, :driver_id)
    end
  end

  describe "#driver_changeset/2" do
    test "should be valid with driver-owned columns", ctx do
      changeset = %Task{} |> Task.driver_changeset(ctx[:driver_attrs])

      assert changeset.valid?
    end

    test "should not cast manager-owned columns", ctx do
      attrs = ctx[:driver_attrs] |> Map.merge(ctx[:manager_attrs])
      changeset = %Task{} |> Task.driver_changeset(attrs)
      changes = changeset.changes

      refute Map.has_key?(changes, :title)
      refute Map.has_key?(changes, :description)
      refute Map.has_key?(changes, :pickup_point)
      refute Map.has_key?(changes, :delivery_point)
      refute Map.has_key?(changes, :manager_id)
    end
  end
end