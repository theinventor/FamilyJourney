class Admin::ReviewsController < Admin::BaseController
  before_action :set_submission, only: [ :show, :approve, :deny ]

  def index
    @pending_submissions = BadgeSubmission.pending_review
      .joins(:badge, :user)
      .where(badges: { family_id: current_family.id })
      .includes(:badge, :user)
      .order(submitted_at: :asc)

    @recent_reviews = BadgeSubmission
      .where(status: [ :approved, :denied ])
      .joins(:badge)
      .where(badges: { family_id: current_family.id })
      .includes(:badge, :user, :reviewed_by)
      .order(reviewed_at: :desc)
      .limit(10)
  end

  def show
  end

  def approve
    @submission.approve!(current_user, feedback: params[:feedback])
    NotificationMailer.badge_approved(@submission).deliver_later if defined?(NotificationMailer) && NotificationMailer.method_defined?(:badge_approved)
    redirect_to admin_reviews_path, notice: "Badge approved! #{@submission.user.name} earned #{@submission.badge.points} points."
  end

  def deny
    if params[:feedback].blank?
      redirect_to admin_review_path(@submission), alert: "Please provide feedback when denying a submission."
      return
    end

    @submission.deny!(current_user, feedback: params[:feedback])
    NotificationMailer.badge_denied(@submission).deliver_later if defined?(NotificationMailer) && NotificationMailer.method_defined?(:badge_denied)
    redirect_to admin_reviews_path, notice: "Submission denied. Feedback sent to #{@submission.user.name}."
  end

  private

  def set_submission
    @submission = BadgeSubmission
      .joins(:badge)
      .where(badges: { family_id: current_family.id })
      .find(params[:id])
  end
end
