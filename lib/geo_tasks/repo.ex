defmodule GeoTasks.Repo do
  use Ecto.Repo,
    otp_app: :geo_tasks,
    adapter: Ecto.Adapters.Postgres
end
