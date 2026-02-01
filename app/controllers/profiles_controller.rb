class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @earned_badges = current_user.badge_submissions.approved.includes(badge: :badge_category).order(created_at: :desc)
    @redemptions = current_user.redemptions.approved.includes(:prize).order(created_at: :desc).limit(10)
  end
end
