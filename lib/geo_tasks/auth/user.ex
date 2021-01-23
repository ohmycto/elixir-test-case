defmodule GeoTasks.Auth.User do
  alias GeoTasks.User
  alias GeoTasks.Auth.Token

  @type user() :: %User{id: String.t()}

  @spec authenticate_by_token(String.t()) :: user() | {:error, String.t()}
  def authenticate_by_token(token) when is_binary(token) do
    case Token.find(token) do
      nil ->
        {:error, "Token not found or revoked."}

      token ->
        token.user
    end
  end
end