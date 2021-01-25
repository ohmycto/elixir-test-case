defmodule GeoTasks.TaskFactory do
  defmacro __using__(_opts) do
    quote do

      def task_factory(attrs \\ %{}) do
        %GeoTasks.Task{
          id: Ecto.UUID.generate(),
          title: sequence(:title, &"My Task #{&1}"),
          description: sequence(:description, &"My Description #{&1}"),
          delivery_point: %Geo.Point{coordinates: {40.7771705, -73.9755112}}
        } |> Map.merge(attrs)
      end

      def set_pickup_point(task, point) do
        %{task | pickup_point: point}
      end

      def set_state(task, state) do
        %{task | state: state}
      end

    end
  end
end