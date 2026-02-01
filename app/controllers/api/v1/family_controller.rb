module Api
  module V1
    class FamilyController < BaseController
      def show
        family = current_user.family

        render json: {
          id: family.id,
          name: family.name,
          created_at: family.created_at,
          updated_at: family.updated_at,
          stats: {
            total_kids: family.kids.count,
            total_badges: family.badges.count,
            published_badges: family.badges.published.count,
            total_prizes: family.prizes.count,
            total_groups: family.groups.count,
            pending_submissions: BadgeSubmission.joins(user: :family)
              .where(users: { family_id: family.id })
              .where(status: "pending_review")
              .count,
            pending_redemptions: Redemption.joins(user: :family)
              .where(users: { family_id: family.id })
              .where(status: "pending")
              .count
          }
        }
      end
    end
  end
end
