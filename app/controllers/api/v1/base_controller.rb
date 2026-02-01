module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_user!

      private

      def authenticate_api_user!
        token = request.headers["Authorization"]&.split(" ")&.last
        return render_unauthorized unless token

        @current_user = User.find_by(api_token: token)
        return render_unauthorized unless @current_user

        # API is only for parents
        render_forbidden unless @current_user.parent?
      end

      def current_user
        @current_user
      end

      def render_unauthorized
        render json: { error: "Unauthorized" }, status: :unauthorized
      end

      def render_forbidden
        render json: { error: "Forbidden - Parent access required" }, status: :forbidden
      end

      def render_not_found(message = "Not found")
        render json: { error: message }, status: :not_found
      end

      def render_unprocessable(errors)
        render json: { errors: errors }, status: :unprocessable_entity
      end

      def render_success(data, status: :ok)
        render json: data, status: status
      end
    end
  end
end
