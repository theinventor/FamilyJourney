module Api
  module V1
    class ChallengesController < BaseController
      def index
        badge_id = params[:badge_id]
        if badge_id.present?
          badge = current_user.family.badges.find(badge_id)
          challenges = badge.badge_challenges
        else
          challenges = BadgeChallenge.joins(:badge).where(badges: { family_id: current_user.family_id })
        end

        render json: challenges.map { |c| challenge_json(c) }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Badge not found")
      end

      def show
        challenge = BadgeChallenge.joins(:badge).where(badges: { family_id: current_user.family_id }).find(params[:id])
        render json: challenge_json(challenge, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Challenge not found")
      end

      def create
        badge = current_user.family.badges.find(params[:badge_id])
        challenge = badge.badge_challenges.build(challenge_params)

        if challenge.save
          render json: challenge_json(challenge, detailed: true), status: :created
        else
          render_unprocessable(challenge.errors.full_messages)
        end
      rescue ActiveRecord::RecordNotFound
        render_not_found("Badge not found")
      end

      def update
        challenge = BadgeChallenge.joins(:badge).where(badges: { family_id: current_user.family_id }).find(params[:id])

        if challenge.update(challenge_params)
          render json: challenge_json(challenge, detailed: true)
        else
          render_unprocessable(challenge.errors.full_messages)
        end
      rescue ActiveRecord::RecordNotFound
        render_not_found("Challenge not found")
      end

      def destroy
        challenge = BadgeChallenge.joins(:badge).where(badges: { family_id: current_user.family_id }).find(params[:id])
        challenge.destroy
        render json: { message: "Challenge deleted successfully" }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Challenge not found")
      end

      private

      def challenge_params
        params.require(:challenge).permit(:description, :position)
      end

      def challenge_json(challenge, detailed: false)
        json = {
          id: challenge.id,
          badge_id: challenge.badge_id,
          description: challenge.description,
          position: challenge.position,
          created_at: challenge.created_at,
          updated_at: challenge.updated_at
        }

        if detailed
          json[:badge] = {
            id: challenge.badge.id,
            title: challenge.badge.title
          }
        end

        json
      end
    end
  end
end
