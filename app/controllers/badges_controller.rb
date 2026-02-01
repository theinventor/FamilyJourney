class BadgesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_badge

  def show
    @state = @badge.state_for(current_user)
    @submission = @badge.badge_submissions.where(user: current_user).order(created_at: :desc).first
    @completions = ChallengeCompletion.where(user: current_user, badge_challenge_id: @badge.badge_challenge_ids)
      .index_by(&:badge_challenge_id)
  end

  private

  def set_badge
    @badge = current_user.family.badges.published.find(params[:id])
  end
end
