module Api
  module V1
    class RedemptionsController < BaseController
      def index
        redemptions = Redemption
          .joins(user: :family)
          .where(users: { family_id: current_user.family_id })
          .includes(:prize, :user)
          .order(created_at: :desc)

        # Filter by status if provided
        redemptions = redemptions.where(status: params[:status]) if params[:status].present?

        render json: redemptions.map { |r| redemption_json(r) }
      end

      def show
        redemption = Redemption
          .joins(user: :family)
          .where(users: { family_id: current_user.family_id })
          .find(params[:id])

        render json: redemption_json(redemption, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Redemption not found")
      end

      def approve
        redemption = Redemption
          .joins(user: :family)
          .where(users: { family_id: current_user.family_id })
          .find(params[:id])

        redemption.approve!(current_user)
        render json: redemption_json(redemption, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Redemption not found")
      end

      def deny
        redemption = Redemption
          .joins(user: :family)
          .where(users: { family_id: current_user.family_id })
          .find(params[:id])

        redemption.deny!(current_user)
        render json: redemption_json(redemption, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Redemption not found")
      end

      private

      def redemption_json(redemption, detailed: false)
        json = {
          id: redemption.id,
          prize_id: redemption.prize_id,
          prize_name: redemption.prize.name,
          user_id: redemption.user_id,
          user_name: redemption.user.name,
          points_spent: redemption.points_spent,
          status: redemption.status,
          redeemed_at: redemption.created_at,
          reviewed_at: redemption.reviewed_at,
          reviewed_by_id: redemption.reviewed_by_id,
          created_at: redemption.created_at,
          updated_at: redemption.updated_at
        }

        if detailed
          json[:prize] = {
            id: redemption.prize.id,
            name: redemption.prize.name,
            description: redemption.prize.description,
            point_cost: redemption.prize.point_cost
          }
        end

        json
      end
    end
  end
end
