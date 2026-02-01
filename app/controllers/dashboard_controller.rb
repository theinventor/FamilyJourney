class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.parent?
      load_parent_dashboard
    else
      load_kid_dashboard
    end
  end

  private

  def load_parent_dashboard
    @pending_reviews = current_user.family.badges
      .joins(:badge_submissions)
      .where(badge_submissions: { status: "pending_review" })
      .distinct.count

    @pending_redemptions = Redemption
      .joins(user: :family)
      .where(users: { family_id: current_user.family_id })
      .where(status: "pending")
      .count

    @total_badges = current_user.family.badges.count
    @published_badges = current_user.family.badges.published.count
    @total_kids = current_user.family.kids.count
    @total_groups = current_user.family.groups.count

    render :parent_dashboard
  end

  def load_kid_dashboard
    # Load all assigned badges for the user and categorize by state
    all_assigned_badges = Badge.published
      .where(family: current_user.family)
      .joins(groups: :group_memberships)
      .where(group_memberships: { user_id: current_user.id })
      .distinct
      .includes(:badge_category, :badge_challenges)

    @earned_badges = []
    @pending_badges = []
    @denied_badges = []
    @ready_badges = []
    @in_progress_badges = []
    @available_badges = []

    all_assigned_badges.each do |badge|
      case badge.state_for(current_user)
      when :earned
        @earned_badges << badge
      when :pending
        @pending_badges << badge
      when :denied
        @denied_badges << badge
      when :ready
        @ready_badges << badge
      when :in_progress
        @in_progress_badges << badge
      else
        @available_badges << badge
      end
    end

    @categories = current_user.family.badge_categories

    render :kid_dashboard
  end
end
