module Api
  module V1
    class BadgeSubmissionsController < BaseController
      def index
        submissions = BadgeSubmission
          .joins(user: :family)
          .where(users: { family_id: current_user.family_id })
          .includes(:badge, :user)
          .order(created_at: :desc)

        # Filter by status if provided
        submissions = submissions.where(status: params[:status]) if params[:status].present?

        render json: submissions.map { |s| submission_json(s) }
      end

      def show
        submission = BadgeSubmission
          .joins(user: :family)
          .where(users: { family_id: current_user.family_id })
          .find(params[:id])

        render json: submission_json(submission, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Submission not found")
      end

      def approve
        submission = BadgeSubmission
          .joins(user: :family)
          .where(users: { family_id: current_user.family_id })
          .find(params[:id])

        submission.approve!(current_user)
        render json: submission_json(submission, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Submission not found")
      end

      def deny
        submission = BadgeSubmission
          .joins(user: :family)
          .where(users: { family_id: current_user.family_id })
          .find(params[:id])

        denial_reason = params[:reason] || "Submission does not meet requirements"
        submission.deny!(current_user, denial_reason)
        render json: submission_json(submission, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Submission not found")
      end

      private

      def submission_json(submission, detailed: false)
        json = {
          id: submission.id,
          badge_id: submission.badge_id,
          badge_title: submission.badge.title,
          user_id: submission.user_id,
          user_name: submission.user.name,
          status: submission.status,
          submitted_at: submission.created_at,
          reviewed_at: submission.reviewed_at,
          reviewed_by_id: submission.reviewed_by_id,
          created_at: submission.created_at,
          updated_at: submission.updated_at
        }

        if detailed
          json[:notes] = submission.notes
          json[:denial_reason] = submission.denial_reason
          json[:badge] = {
            id: submission.badge.id,
            title: submission.badge.title,
            description: submission.badge.description,
            points: submission.badge.points
          }
        end

        json
      end
    end
  end
end
