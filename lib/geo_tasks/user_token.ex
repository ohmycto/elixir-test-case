defmodule GeoTasks.UserToken do
  use GeoTasks.Schema
  alias GeoTasks.UserToken
  alias GeoTasks.Auth.Token

  schema "user_tokens" do
    field :token, :string
    field :revoked_at, :utc_datetime
    belongs_to :user, GeoTasks.User

    timestamps()
  end

  def insert_changeset(%UserToken{} = token, attrs) do
    token
    |> cast(attrs, [:user_id])
    |> generate_token()
    |> validate_required([:token, :user_id])
    |> unique_constraint(:token)
  end

  def revoke_changeset(%UserToken{} = token, attrs \\ %{}) do
    token
    |> cast(attrs, [])
    |> set_revoked_at()
  end

  defp generate_token(changeset) do
    changeset |> put_change(:token, Token.generate())
  end

  defp set_revoked_at(changeset) do
    changeset |> put_change(:revoked_at, DateTime.utc_now() |> DateTime.truncate(:second))
  end
end