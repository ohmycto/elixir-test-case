defmodule GeoTasks.UserToken do
  use GeoTasks.Schema
  alias GeoTasks.UserToken

  @token_length 32

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
    new_token = @token_length |> :crypto.strong_rand_bytes() |> Base.url_encode64 |> binary_part(0, @token_length)
    changeset |> put_change(:token, new_token)
  end

  defp set_revoked_at(changeset) do
    changeset |> put_change(:revoked_at, DateTime.utc_now())
  end
end