defmodule GeoTasks.Repo.Migrations.CreateUserToken do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :token, :text, null: false
      add :user_id, references(:users), null: false
      add :revoked_at, :utc_datetime

      timestamps()
    end

    create index(:user_tokens, [:token], unique: true)
    create index(:user_tokens, [:user_id])
  end
end
