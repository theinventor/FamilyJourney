class Redemption < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :prize
  belongs_to :user
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :status, {
    pending: "pending",
    approved: "approved",
    denied: "denied"
  }, default: :pending

  validate :user_can_afford_prize, on: :create

  before_create :set_requested_at
  before_create :set_points_spent

  # Broadcast when redemption is created (parent sees new request)
  after_create_commit :broadcast_new_redemption
  # Broadcast when reviewed (kid sees result, points update)
  after_update_commit :broadcast_redemption_reviewed, if: :saved_change_to_status?

  def approve!(reviewer, feedback: nil)
    return false unless user_can_still_afford?

    update!(
      status: :approved,
      reviewed_by: reviewer,
      reviewed_at: Time.current,
      parent_feedback: feedback
    )
  end

  def deny!(reviewer, feedback:)
    update!(
      status: :denied,
      reviewed_by: reviewer,
      reviewed_at: Time.current,
      parent_feedback: feedback,
      points_spent: 0
    )
  end

  def user_can_still_afford?
    user.available_points >= prize.point_cost
  end

  def family
    user.family
  end

  private

  def broadcast_new_redemption
    # Notify parents about new prize request
    broadcast_refresh_to family, "parent_dashboard"
    broadcast_refresh_to family, "redemptions_admin"
  end

  def broadcast_redemption_reviewed
    # Notify the kid about their redemption result
    broadcast_refresh_to family, "kid_dashboard_#{user_id}"
    broadcast_refresh_to family, "redemptions_kid_#{user_id}"
    # Update parent dashboard stats
    broadcast_refresh_to family, "parent_dashboard"
    broadcast_refresh_to family, "redemptions_admin"
  end

  def user_can_afford_prize
    unless user.can_afford?(prize)
      errors.add(:base, "You don't have enough points for this prize")
    end
  end

  def set_requested_at
    self.requested_at ||= Time.current
  end

  def set_points_spent
    self.points_spent = prize.point_cost
  end
end
