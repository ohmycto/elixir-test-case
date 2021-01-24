defmodule GeoTasks.Repo.Migrations.CreateTask do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :text, null: false
      add :description, :text, null: false
      add :state, :text, null: false, default: "new"
      add :pickup_point, :geography, null: false
      add :delivery_point, :geography, null: false
      add :manager_id, references(:users), null: false
      add :driver_id, references(:users)

      timestamps()
    end
  end
end
