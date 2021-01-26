defmodule GeoTasksWeb.TaskView do
  use GeoTasksWeb, :view

  def render("index.json", %{tasks: tasks}) do
    %{result: :ok, tasks: tasks}
  end
end