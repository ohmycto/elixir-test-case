defmodule GeoTasks.TaskStateMachine do
  alias GeoTasks.Task

  use Machinery,
    states: ["new", "assigned", "done"],
    transitions: %{
      "new" =>  "assigned",
      "assigned" => "done"
    }

  def guard_transition(%Task{driver_id: nil}, "assigned"), do: {:error, "driver_id must be set"}
  def guard_transition(%Task{}, "assigned"), do: :ok
end