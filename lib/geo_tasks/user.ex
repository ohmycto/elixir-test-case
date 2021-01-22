defmodule GeoTasks.User do
  use GeoTasks.Schema
  alias GeoTasks.User

  schema "users" do
    field :name, :string
    field :role, Ecto.Enum, values: [:manager, :driver]
    has_many :auth_tokens, GeoTasks.UserToken

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :role])
    |> validate_required([:name, :role])
  end
end