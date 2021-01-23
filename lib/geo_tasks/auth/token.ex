defmodule GeoTasks.Auth.Token do
  import Ecto.Query
  alias GeoTasks.{Repo, User, UserToken}

  @token_length 32

  @type user() :: %User{id: String.t()}
  @type user_token() :: %UserToken{token: String.t()}

  @spec create_for_user(user()) :: {:ok, user_token()} | {:error, String.t()}
  def create_for_user(%User{id: user_id}) do
    %UserToken{}
    |> UserToken.insert_changeset(%{user_id: user_id})
    |> Repo.insert()
  end

  @spec find(user_token() | String.t()) :: user_token() | nil
  def find(%UserToken{token: token}), do: find(token)
  def find(token) do
    UserToken
    |> where([t], t.token == ^token and is_nil(t.revoked_at))
    |> first()
    |> Repo.one()
    |> Repo.preload([:user])
  end

  @spec revoke!(user_token()) :: {:ok, user_token()} | {:ignore, user_token()}
  def revoke!(%UserToken{revoked_at: nil} = token) do
    token
    |> UserToken.revoke_changeset()
    |> Repo.update()
  end
  def revoke!(%UserToken{} = token), do: {:ignore, token}

  @spec generate() :: String.t()
  def generate() do
    @token_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64
    |> binary_part(0, @token_length)
  end
end