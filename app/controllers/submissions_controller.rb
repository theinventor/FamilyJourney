class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_kid!
  before_action :set_badge, only: [ :new, :create ]

  def new
    if @badge.earned_by?(current_user)
      redirect_to badge_path(@badge), alert: "You've already earned this badge!"
      return
    end

    if @badge.pending_for?(current_user)
      redirect_to badge_path(@badge), alert: "You already have a pending submission for this badge."
      return
    end

    unless @badge.all_challenges_completed_for?(current_user)
      redirect_to badge_path(@badge), alert: "Please complete all challenges first."
      return
    end

    @submission = @badge.badge_submissions.build
  end

  def create
    if @badge.earned_by?(current_user)
      redirect_to badge_path(@badge), alert: "You've already earned this badge!"
      return
    end

    if @badge.pending_for?(current_user)
      redirect_to badge_path(@badge), alert: "You already have a pending submission for this badge."
      return
    end

    @submission = @badge.badge_submissions.build(submission_params)
    @submission.user = current_user

    if @submission.save
      NotificationMailer.badge_submitted(@submission).deliver_later if defined?(NotificationMailer)
      redirect_to badge_path(@badge), notice: "Submission sent for review!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @submission = current_user.badge_submissions.find(params[:id])
    @badge = @submission.badge
  end

  private

  def require_kid!
    unless current_user.kid?
      redirect_to dashboard_path, alert: "Only kids can submit badges."
    end
  end

  def set_badge
    @badge = current_user.family.badges.published.find(params[:badge_id])
  end

  def submission_params
    params.require(:badge_submission).permit(:kid_notes, :evidence, attachments: [])
  end
end
