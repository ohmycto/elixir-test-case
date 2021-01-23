defmodule GeoTasks.Auth.UserTest do
  use GeoTasks.DataCase
  alias GeoTasks.Auth.User

  setup do
    user = build(:user) |> make_manager() |> insert()
    active_token = build(:user_token) |> assign_user(user) |> insert()
    revoked_token = build(:user_token) |> assign_user(user) |> make_revoked() |> insert()

    [
      user: user,
      active_token: active_token,
      revoked_token: revoked_token
    ]
  end

  describe "#authenticate_by_token/1" do
    test "should return User when given a valid token", ctx do
      assert User.authenticate_by_token(ctx[:active_token].token) == ctx[:user]
    end

    test "should return error when given a revoked token", ctx do
      assert User.authenticate_by_token(ctx[:revoked_token].token) == {:error, "Token not found or revoked."}
    end

    test "should return error when given a nonexistent token" do
      assert User.authenticate_by_token("foo") == {:error, "Token not found or revoked."}
    end
  end
end