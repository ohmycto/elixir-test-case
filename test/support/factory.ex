defmodule GeoTasks.Factory do
  use ExMachina.Ecto, repo: GeoTasks.Repo
  use GeoTasks.UserFactory
  use GeoTasks.UserTokenFactory


  defmodule Helpers do

    # Empire State Building
    def geo_empire_state() do
      %Geo.Point{coordinates: {40.75010051199758, -73.98571864017009}, srid: 4326}
    end

    # Times Square
    def geo_times_square() do
      %Geo.Point{coordinates: {40.75814756178693, -73.98555802324617}, srid: 4326}
    end

    # Linkoln Center
    def geo_linkoln_center() do
      %Geo.Point{coordinates: {40.77369939027879, -73.98314371956167}, srid: 4326}
    end
  end
end