class ChallengeCompletion < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :badge_challenge
  belongs_to :user

  has_many_attached :attachments

  validates :badge_challenge_id, uniqueness: { scope: :user_id, message: "already completed" }

  before_create :set_completed_at
  after_create_commit :broadcast_completion

  def badge
    badge_challenge.badge
  end

  def family
    user.family
  end

  private

  def set_completed_at
    self.completed_at ||= Time.current
  end

  def broadcast_completion
    # Update the kid's dashboard to show progress
    broadcast_refresh_to family, "kid_dashboard_#{user_id}"
  end
end
