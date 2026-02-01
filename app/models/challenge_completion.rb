class ChallengeCompletion < ApplicationRecord
  belongs_to :badge_challenge
  belongs_to :user

  has_many_attached :attachments

  validates :badge_challenge_id, uniqueness: { scope: :user_id, message: "already completed" }

  before_create :set_completed_at

  def badge
    badge_challenge.badge
  end

  private

  def set_completed_at
    self.completed_at ||= Time.current
  end
end
