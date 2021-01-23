defmodule GeoTasks.UserTokenFactory do
  defmacro __using__(_opts) do
    quote do

      def user_token_factory() do
        %GeoTasks.UserToken{
          token: GeoTasks.Auth.Token.generate()
        }
      end

      def assign_user(user_token, user) do
        %{user_token | user_id: user.id}
      end

      def make_revoked(user_token) do
        %{user_token | revoked_at: DateTime.utc_now()}
      end
    end
  end
end