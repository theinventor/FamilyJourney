class BadgeSubmission < ApplicationRecord
  belongs_to :badge
  belongs_to :user
  belongs_to :reviewed_by, class_name: "User", optional: true

  has_many_attached :attachments

  enum :status, {
    pending_review: "pending_review",
    approved: "approved",
    denied: "denied"
  }, default: :pending_review

  scope :pending, -> { pending_review }

  before_create :set_submitted_at

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

  private

  def set_submitted_at
    self.submitted_at ||= Time.current
  end
end
