defmodule GeoTasks.UserTest do
  use GeoTasks.DataCase
  alias GeoTasks.User

  describe "#changeset/2" do
    test "should not be valid with empty role" do
      changeset = %User{} |> User.changeset(%{name: "John"})
      refute changeset.valid?
    end

    test "should not be valid with empty name" do
      changeset = %User{} |> User.changeset(%{role: :manager})
      refute changeset.valid?
    end

    test "should not be valid with unexpected role" do
      changeset = %User{} |> User.changeset(%{role: :invalid})
      refute changeset.valid?
    end

    test "should be valid with unique name and proper role" do
      changeset = %User{} |> User.changeset(%{name: "John the Driver", role: :driver})
      assert changeset.valid?
    end
  end
end