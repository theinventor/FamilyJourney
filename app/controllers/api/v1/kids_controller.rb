module Api
  module V1
    class KidsController < BaseController
      def index
        kids = current_user.family.kids.includes(:groups)
        render json: kids.map { |k| kid_json(k) }
      end

      def show
        kid = current_user.family.kids.find(params[:id])
        render json: kid_json(kid, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Kid not found")
      end

      def create
        kid = current_user.family.users.build(kid_params.merge(role: "kid"))
        kid.password = SecureRandom.hex(8)

        if kid.save
          render json: kid_json(kid, detailed: true).merge(password: kid.password), status: :created
        else
          render_unprocessable(kid.errors.full_messages)
        end
      end

      def update
        kid = current_user.family.kids.find(params[:id])

        if kid.update(kid_params)
          render json: kid_json(kid, detailed: true)
        else
          render_unprocessable(kid.errors.full_messages)
        end
      rescue ActiveRecord::RecordNotFound
        render_not_found("Kid not found")
      end

      def destroy
        kid = current_user.family.kids.find(params[:id])
        kid.destroy
        render json: { message: "Kid deleted successfully" }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Kid not found")
      end

      def reset_password
        kid = current_user.family.kids.find(params[:id])
        new_password = SecureRandom.hex(8)
        kid.update!(password: new_password, password_confirmation: new_password)

        render json: { message: "Password reset successfully", password: new_password }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Kid not found")
      end

      private

      def kid_params
        params.require(:kid).permit(:name, :email, group_ids: [])
      end

      def kid_json(kid, detailed: false)
        json = {
          id: kid.id,
          name: kid.name,
          email: kid.email,
          available_points: kid.available_points,
          lifetime_points: kid.lifetime_points,
          spent_points: kid.spent_points,
          created_at: kid.created_at,
          updated_at: kid.updated_at
        }

        if detailed
          json[:groups] = kid.groups.map { |g| { id: g.id, name: g.name } }
          json[:earned_badges_count] = kid.badge_submissions.approved.count
          json[:pending_submissions_count] = kid.badge_submissions.pending_review.count
        end

        json
      end
    end
  end
end
