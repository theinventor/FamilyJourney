module Api
  module V1
    class PrizesController < BaseController
      def index
        prizes = current_user.family.prizes
        render json: prizes.map { |p| prize_json(p) }
      end

      def show
        prize = current_user.family.prizes.find(params[:id])
        render json: prize_json(prize, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Prize not found")
      end

      def create
        prize = current_user.family.prizes.build(prize_params)

        if prize.save
          render json: prize_json(prize, detailed: true), status: :created
        else
          render_unprocessable(prize.errors.full_messages)
        end
      end

      def update
        prize = current_user.family.prizes.find(params[:id])

        if prize.update(prize_params)
          render json: prize_json(prize, detailed: true)
        else
          render_unprocessable(prize.errors.full_messages)
        end
      rescue ActiveRecord::RecordNotFound
        render_not_found("Prize not found")
      end

      def destroy
        prize = current_user.family.prizes.find(params[:id])
        prize.destroy
        render json: { message: "Prize deleted successfully" }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Prize not found")
      end

      private

      def prize_params
        params.require(:prize).permit(:name, :description, :point_cost, :active, :image)
      end

      def prize_json(prize, detailed: false)
        json = {
          id: prize.id,
          name: prize.name,
          description: prize.description,
          point_cost: prize.point_cost,
          active: prize.active,
          created_at: prize.created_at,
          updated_at: prize.updated_at
        }

        if prize.image.attached?
          json[:image_url] = Rails.application.routes.url_helpers.rails_blob_url(
            prize.image,
            host: request.base_url
          )
        end

        json
      end
    end
  end
end
