defmodule GeoTasks.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :text, null: false
      add :role, :text, null: false

      timestamps()
    end
  end
end
