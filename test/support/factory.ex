defmodule GeoTasks.Factory do
  use ExMachina.Ecto, repo: GeoTasks.Repo
  use GeoTasks.UserFactory
  use GeoTasks.UserTokenFactory
end