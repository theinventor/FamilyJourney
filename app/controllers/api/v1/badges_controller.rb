module Api
  module V1
    class BadgesController < BaseController
      def index
        badges = current_user.family.badges.includes(:badge_category, :badge_challenges, :groups)
        render json: badges.map { |b| badge_json(b) }
      end

      def show
        badge = current_user.family.badges.find(params[:id])
        render json: badge_json(badge, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Badge not found")
      end

      def create
        badge = current_user.family.badges.build(badge_params)
        badge.created_by = current_user

        if badge.save
          render json: badge_json(badge, detailed: true), status: :created
        else
          render_unprocessable(badge.errors.full_messages)
        end
      end

      def update
        badge = current_user.family.badges.find(params[:id])

        if badge.update(badge_params)
          render json: badge_json(badge, detailed: true)
        else
          render_unprocessable(badge.errors.full_messages)
        end
      rescue ActiveRecord::RecordNotFound
        render_not_found("Badge not found")
      end

      def destroy
        badge = current_user.family.badges.find(params[:id])
        badge.destroy
        render json: { message: "Badge deleted successfully" }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Badge not found")
      end

      def publish
        badge = current_user.family.badges.find(params[:id])
        badge.publish!
        render json: badge_json(badge, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Badge not found")
      end

      def unpublish
        badge = current_user.family.badges.find(params[:id])
        badge.unpublish!
        render json: badge_json(badge, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Badge not found")
      end

      private

      def badge_params
        params.require(:badge).permit(
          :title,
          :description,
          :points,
          :status,
          :badge_category_id,
          group_ids: [],
          badge_challenges_attributes: [ :id, :description, :position, :_destroy ]
        )
      end

      def badge_json(badge, detailed: false)
        json = {
          id: badge.id,
          title: badge.title,
          description: badge.description,
          points: badge.points,
          status: badge.status,
          published_at: badge.published_at,
          badge_category_id: badge.badge_category_id,
          badge_category_name: badge.badge_category&.name,
          multi_challenge: badge.multi_challenge?,
          created_at: badge.created_at,
          updated_at: badge.updated_at
        }

        if detailed
          json[:groups] = badge.groups.map { |g| { id: g.id, name: g.name } }
          json[:challenges] = badge.badge_challenges.map do |c|
            { id: c.id, description: c.description, position: c.position }
          end
        end

        json
      end
    end
  end
end
