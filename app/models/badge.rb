class Badge < ApplicationRecord
  belongs_to :badge_category, optional: true
  belongs_to :family
  belongs_to :created_by, class_name: "User"
  has_many :badge_assignments, dependent: :destroy
  has_many :groups, through: :badge_assignments
  has_many :badge_challenges, -> { order(position: :asc) }, dependent: :destroy
  has_many :badge_submissions, dependent: :destroy

  accepts_nested_attributes_for :badge_challenges, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true
  validates :points, numericality: { greater_than_or_equal_to: 0 }

  enum :status, { draft: "draft", published: "published" }, default: :draft

  scope :visible, -> { published }
  scope :by_category, -> { includes(:badge_category).order("badge_categories.position ASC, badges.title ASC") }

  def publish!
    update!(status: :published, published_at: Time.current)
  end

  def unpublish!
    update!(status: :draft, published_at: nil)
  end

  def multi_challenge?
    badge_challenges.any?
  end

  def available_for?(user)
    return false unless published?
    return false unless assigned_to_user?(user)
    !earned_by?(user)
  end

  def assigned_to_user?(user)
    (group_ids & user.group_ids).any?
  end

  def earned_by?(user)
    badge_submissions.approved.where(user: user).exists?
  end

  def in_progress_for?(user)
    return false unless assigned_to_user?(user)
    return false if earned_by?(user)
    return false unless multi_challenge?

    completed_count = ChallengeCompletion.where(
      user: user,
      badge_challenge_id: badge_challenge_ids
    ).count
    completed_count > 0 && completed_count < badge_challenges.count
  end

  def pending_for?(user)
    badge_submissions.pending_review.where(user: user).exists?
  end

  def challenges_completed_for(user)
    return 0 unless multi_challenge?
    ChallengeCompletion.where(user: user, badge_challenge_id: badge_challenge_ids).count
  end

  def all_challenges_completed_for?(user)
    return true unless multi_challenge?
    challenges_completed_for(user) >= badge_challenges.count
  end

  def state_for(user)
    return :earned if earned_by?(user)
    return :pending if pending_for?(user)
    return :denied if denied_for?(user)
    return :ready if multi_challenge? && all_challenges_completed_for?(user)
    return :in_progress if in_progress_for?(user)
    :available
  end

  def denied_for?(user)
    latest = badge_submissions.where(user: user).order(created_at: :desc).first
    latest&.denied?
  end
end
