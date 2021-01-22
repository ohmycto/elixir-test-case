defmodule GeoTasks.UserFactory do
  defmacro __using__(_opts) do
    quote do

      def user_factory do
        %GeoTasks.User{
          id: Ecto.UUID.generate(),
          name: sequence(:name, &"User #{&1}")
        }
      end

      def make_driver(user) do
        %{user | role: :driver}
      end

      def make_manager(user) do
        %{user | role: :manager}
      end

    end
  end
end