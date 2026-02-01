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
    @available_badges = available_badges
    @in_progress_badges = in_progress_badges
    @pending_badges = pending_badges
    @earned_badges = earned_badges
    @categories = current_user.family.badge_categories

    render :kid_dashboard
  end

  def available_badges
    Badge.published
      .where(family: current_user.family)
      .joins(groups: :group_memberships)
      .where(group_memberships: { user_id: current_user.id })
      .where.not(id: earned_badge_ids)
      .where.not(id: pending_badge_ids)
      .distinct
      .includes(:badge_category, :badge_challenges)
  end

  def in_progress_badges
    return Badge.none unless multi_challenge_badge_ids.any?

    Badge.where(id: multi_challenge_badge_ids)
      .where.not(id: earned_badge_ids)
      .where.not(id: pending_badge_ids)
      .joins(:badge_challenges)
      .where(
        "badge_challenges.id IN (?)",
        ChallengeCompletion.where(user: current_user).select(:badge_challenge_id)
      )
      .distinct
      .includes(:badge_category, :badge_challenges)
  end

  def pending_badges
    Badge.joins(:badge_submissions)
      .where(badge_submissions: { user_id: current_user.id, status: "pending_review" })
      .distinct
      .includes(:badge_category)
  end

  def earned_badges
    Badge.joins(:badge_submissions)
      .where(badge_submissions: { user_id: current_user.id, status: "approved" })
      .distinct
      .includes(:badge_category)
  end

  def earned_badge_ids
    BadgeSubmission.where(user: current_user, status: "approved").select(:badge_id)
  end

  def pending_badge_ids
    BadgeSubmission.where(user: current_user, status: "pending_review").select(:badge_id)
  end

  def multi_challenge_badge_ids
    Badge.published
      .where(family: current_user.family)
      .joins(:badge_challenges)
      .distinct
      .pluck(:id)
  end
end
