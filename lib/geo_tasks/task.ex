defmodule GeoTasks.Task do
  use GeoTasks.Schema
  alias GeoTasks.{Task, User}

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :state, :string, default: "new"
    field :pickup_point, Geo.PostGIS.Geometry
    field :delivery_point, Geo.PostGIS.Geometry
    belongs_to :manager, User, foreign_key: :manager_id
    belongs_to :driver, User, foreign_key: :driver_id

    timestamps()
  end

  @manager_columns [:title, :description, :pickup_point, :delivery_point, :manager_id]
  @driver_columns [:state, :driver_id]

  def manager_changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, @manager_columns)
    |> validate_required(@manager_columns)
  end

  def driver_changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, @driver_columns)
    |> validate_required(@driver_columns)
  end
end