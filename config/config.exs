# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :geo_tasks,
  ecto_repos: [GeoTasks.Repo],
  generators: [binary_id: true]

config :geo_tasks, GeoTasks.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  types: GeoTasks.PostgrexTypes

# Configures the endpoint
config :geo_tasks, GeoTasksWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ijsLQiW67JIIIUx239YUcu/3AhL/Qoxd0xzdSc0UIf5T6jk1PPkPavY3mCIv/x1V",
  render_errors: [view: GeoTasksWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: GeoTasks.PubSub,
  live_view: [signing_salt: "vyjVUqiW"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix and PostGIS
config :phoenix, :json_library, Jason
config :geo_postgis, json_library: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
