defmodule GeoTasks.UserTokenTest do
  use GeoTasks.DataCase
  alias GeoTasks.UserToken

  describe "#insert_changeset/2" do
    test "should not be valid with empty user_id" do
      changeset = %UserToken{} |> UserToken.insert_changeset(%{})
      refute changeset.valid?
    end

    test "should generate token and be valid when user_id provided" do
      changeset = %UserToken{} |> UserToken.insert_changeset(%{user_id: "xxx"})
      assert changeset.valid?
      assert changeset.changes[:token]
    end
  end

  describe "#revoke_changeset/2" do
    test "should set rekoved_at to current time" do
      changeset = %UserToken{} |> UserToken.revoke_changeset()
      assert changeset.valid?
      assert changeset.changes[:revoked_at]
    end
  end
end