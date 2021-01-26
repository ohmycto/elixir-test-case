defmodule GeoTasks.TaskValidatorTest do
  use GeoTasks.DataCase
  alias GeoTasks.TaskValidator

  setup do
    [
      valid_attrs: %{
        "title" => "My task",
        "description" => "Task description",
        "pickup_point" => %{"lat" => 40.75010051199758, "lng" => -73.98571864017009},
        "delivery_point" => %{"lat" => 40.75814756178693, "lng" => -73.98555802324617}
      }
    ]
  end

  test "should return ok for valid attributes", ctx do
    assert TaskValidator.valid?(ctx[:valid_attrs])
    assert TaskValidator.validate(ctx[:valid_attrs]) == :ok
  end

  test "should return error with 'required' reason when some of the required fields missing", ctx do
    attrs = ctx[:valid_attrs] |> Map.delete("title")

    refute TaskValidator.valid?(attrs)
    {:error, %JsonXema.ValidationError{reason: reason}} = TaskValidator.validate(attrs)

    assert reason == %{required: ["title"]}
  end

  test "should return error with 'properties' reason when some of the required fields are broken", ctx do
    attrs = ctx[:valid_attrs] |> Map.put("pickup_point", "40.75010051199758,-73.98571864017009")

    refute TaskValidator.valid?(attrs)
    {:error, %JsonXema.ValidationError{reason: reason}} = TaskValidator.validate(attrs)

    assert reason == %{properties: %{"pickup_point" => %{type: "object", value: "40.75010051199758,-73.98571864017009"}}}
  end
end
