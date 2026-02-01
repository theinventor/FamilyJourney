class ChallengeCompletionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_kid!
  before_action :set_challenge

  def new
    if @challenge.completed_by?(current_user)
      redirect_to badge_path(@badge), alert: "You've already completed this challenge!"
      return
    end

    @completion = ChallengeCompletion.new
  end

  def create
    if @challenge.completed_by?(current_user)
      redirect_to badge_path(@badge), alert: "You've already completed this challenge!"
      return
    end

    @completion = ChallengeCompletion.new(completion_params)
    @completion.badge_challenge = @challenge
    @completion.user = current_user

    if @completion.save
      redirect_to badge_path(@badge), notice: "Challenge completed!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def require_kid!
    unless current_user.kid?
      redirect_to dashboard_path, alert: "Only kids can complete challenges."
    end
  end

  def set_challenge
    @challenge = BadgeChallenge.joins(:badge)
      .where(badges: { family_id: current_user.family_id, status: "published" })
      .find(params[:badge_challenge_id])
    @badge = @challenge.badge
  end

  def completion_params
    params.require(:challenge_completion).permit(:kid_notes, attachments: [])
  end
end
