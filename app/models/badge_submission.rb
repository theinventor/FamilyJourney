class BadgeSubmission < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :badge
  belongs_to :user
  belongs_to :reviewed_by, class_name: "User", optional: true

  has_rich_text :evidence
  has_many_attached :attachments

  enum :status, {
    pending_review: "pending_review",
    approved: "approved",
    denied: "denied"
  }, default: :pending_review

  scope :pending, -> { pending_review }

  before_create :set_submitted_at

  # Broadcast to family when submission is created (parent sees new review)
  after_create_commit :broadcast_new_submission
  # Broadcast when submission is reviewed (kid sees result, parent stats update)
  after_update_commit :broadcast_submission_reviewed, if: :saved_change_to_status?

  def approve!(reviewer, feedback: nil)
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
      parent_feedback: feedback
    )
  end

  def family
    badge.family
  end

  private

  def set_submitted_at
    self.submitted_at ||= Time.current
  end

  def broadcast_new_submission
    # Notify parents about new submission (refresh review counts and list)
    broadcast_refresh_to family, "parent_dashboard"
    broadcast_refresh_to family, "reviews"
  end

  def broadcast_submission_reviewed
    # Notify the kid about their submission result
    broadcast_refresh_to family, "kid_dashboard_#{user_id}"
    # Update parent dashboard stats
    broadcast_refresh_to family, "parent_dashboard"
    broadcast_refresh_to family, "reviews"
  end
end
