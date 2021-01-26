defmodule GeoTasks.TaskValidator do
  @geo_point_schema %{
    "type" => "object",
    "properties" => %{
      "lat" => %{
        "type" => "number"
      },
      "lng" => %{
        "type" => "number"
      }
    }
  }

  @task_schema %{
    "type" => "object",
    "properties" => %{
      "title" => %{
        "type" => "string"
      },
      "description" => %{
        "type" => "string"
      },
      "pickup_point" => @geo_point_schema,
      "delivery_point" => @geo_point_schema
    },
    "required" => [
      "title",
      "description",
      "pickup_point",
      "delivery_point"
    ]
  } |> JsonXema.new()

  def valid?(payload) do
    JsonXema.valid?(@task_schema, payload)
  end

  def validate(payload) do
    JsonXema.validate(@task_schema, payload)
  end
end