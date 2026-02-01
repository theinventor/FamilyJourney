class BadgeChallenge < ApplicationRecord
  belongs_to :badge
  has_many :challenge_completions, dependent: :destroy

  validates :title, presence: true

  default_scope { order(position: :asc) }

  before_create :set_position

  def completed_by?(user)
    challenge_completions.where(user: user).exists?
  end

  private

  def set_position
    max_position = badge.badge_challenges.unscoped.maximum(:position) || 0
    self.position = max_position + 1
  end
end
