# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GeoTasks.Repo.insert!(%GeoTasks.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias GeoTasks.{Repo, User}
alias GeoTasks.Auth.Token

defmodule UserSeed do
  def create_user(name, role) do
    {:ok, user} = %User{name: name, role: role} |> Repo.insert()
    {:ok, user_token} = Token.create_for_user(user)
    user_token.token
  end
end

[
  {"John", :manager},
  {"Mary", :manager},
  {"Jack", :driver},
  {"Emma", :driver}
] |> Enum.reduce([], fn({name, role}, acc) ->
  token = UserSeed.create_user(name, role)
  acc ++ [%{name: name, role: role, token: token}]
end)
|> Scribe.print()
