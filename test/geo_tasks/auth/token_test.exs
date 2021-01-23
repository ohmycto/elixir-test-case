defmodule GeoTasks.Auth.TokenTest do
  use GeoTasks.DataCase
  alias GeoTasks.{User, UserToken}
  alias GeoTasks.Auth.Token

  setup do
    [
      user: build(:user) |> make_manager() |> insert()
    ]
  end

  describe "#create_for_user/1" do
    test "should create a new UserToken for a given User", ctx do
      {:ok, %UserToken{} = user_token} = ctx[:user] |> Token.create_for_user()

      assert user_token.user_id == ctx[:user].id
      refute user_token.revoked_at
    end

    test "should allow to create multiple UserTokens for a given User", ctx do
      {:ok, %UserToken{} = user_token_1} = ctx[:user] |> Token.create_for_user()
      {:ok, %UserToken{} = user_token_2} = ctx[:user] |> Token.create_for_user()

      assert user_token_1.user_id == ctx[:user].id
      refute user_token_1.revoked_at

      assert user_token_2.user_id == ctx[:user].id
      refute user_token_2.revoked_at
    end

    test "should return an error when given a nonexistent User" do
      {:error, %Ecto.Changeset{} = err_changeset} = %User{name: "Defunct"} |> Token.create_for_user()

      refute err_changeset.valid?
    end
  end

  describe "#find/1" do
    setup ctx do
      [
        active_token: build(:user_token) |> assign_user(ctx[:user]) |> insert(),
        revoked_token: build(:user_token) |> assign_user(ctx[:user]) |> make_revoked() |> insert(),
        nonexistent_token: build(:user_token) |> assign_user(ctx[:user])
      ]
    end

    test "should return a UserToken with preloaded User when given a binary value of active token", ctx do
      user_token = ctx[:active_token].token |> Token.find()

      assert user_token.user == ctx[:user]
    end

    test "should return a UserToken with preloaded User when given a UserToken struct active token", ctx do
      user_token = ctx[:active_token] |> Token.find()

      assert user_token.user == ctx[:user]
    end

    test "should return error when given a binary value of revoked token", ctx do
      refute ctx[:revoked_token].token |> Token.find()
    end

    test "should return error when given a UserToken struct of revoked token", ctx do
      refute ctx[:revoked_token] |> Token.find()
    end

    test "should return error when given a binary value of nonexistent token", ctx do
      refute ctx[:nonexistent_token].token |> Token.find()
    end

    test "should return error when given a UserToken struct of nonexistent token", ctx do
      refute ctx[:nonexistent_token] |> Token.find()
    end
  end

  describe "#revoke!/1" do
    setup ctx do
      [
        active_token: build(:user_token) |> assign_user(ctx[:user]) |> insert(),
        revoked_token: build(:user_token) |> assign_user(ctx[:user]) |> make_revoked() |> insert()
      ]
    end

    test "should mark given active UserToken as revoked", ctx do
      {:ok, %UserToken{revoked_at: revoked_at}} = ctx[:active_token] |> Token.revoke!()

      assert revoked_at
    end

    test "should ignore given UserToken if it is already revoked", ctx do
      {:ignore, %UserToken{revoked_at: revoked_at}} = ctx[:revoked_token] |> Token.revoke!()

      assert revoked_at == ctx[:revoked_token].revoked_at
    end
  end

  describe "#generate/0" do
    test "should generate a random URL-safe string" do
      assert Token.generate() |> is_binary()
    end
  end
end