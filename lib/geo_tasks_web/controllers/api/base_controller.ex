defmodule GeoTasksWeb.API.BaseController do
  defmacro __using__(_opts) do
    quote do
      use GeoTasksWeb, :controller
      alias GeoTasksWeb.ErrorHelpers

      def respond_ok(conn) do
        conn |> put_status(:ok) |> json(%{result: :ok})
      end
      def respond_ok(conn, entity) do
        conn |> put_status(:ok) |> json(%{result: :ok, entity: entity})
      end

      def respond_created(conn, entity) do
        conn |> put_status(:created) |> json(%{result: :ok, entity: entity})
      end

      def respond_bad_request(conn, errors) do
        conn |> put_status(:bad_request) |> json(%{result: :error, errors: ErrorHelpers.get_result_errors(errors)})
      end

      def respond_not_found(conn, errors) do
        conn |> put_status(:not_found) |> json(%{result: :error, errors: ErrorHelpers.get_result_errors(errors)})
      end

      def respond_unprocessable_entity(conn, errors) do
        conn |> put_status(:unprocessable_entity) |> json(%{result: :error, errors: ErrorHelpers.get_result_errors(errors)})
      end

      def respond_unauthorized(conn, errors \\ "You're not authorized to use this resource") do
        conn |> put_status(:unauthorized) |> json(%{result: :error, errors: ErrorHelpers.get_result_errors(errors)})
      end
    end
  end
end