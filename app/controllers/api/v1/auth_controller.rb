module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_api_user!, only: [ :login ]

      def login
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password]) && user.parent?
          # Generate token if not exists
          user.regenerate_api_token! unless user.api_token

          render json: {
            token: user.api_token,
            user: user_json(user)
          }, status: :ok
        else
          render json: { error: "Invalid credentials or not a parent account" }, status: :unauthorized
        end
      end

      def logout
        current_user.regenerate_api_token!
        render json: { message: "Logged out successfully" }, status: :ok
      end

      def me
        render json: { user: user_json(current_user) }, status: :ok
      end

      private

      def user_json(user)
        {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          family_id: user.family_id
        }
      end
    end
  end
end
