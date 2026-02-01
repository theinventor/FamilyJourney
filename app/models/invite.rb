class Invite < ApplicationRecord
  belongs_to :family
  belongs_to :invited_by, class_name: "User"
  belongs_to :accepted_by, class_name: "User", optional: true

  validates :token, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[pending accepted expired cancelled] }
  validates :expires_at, presence: true
  validate :invited_by_must_be_parent

  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  scope :pending, -> { where(status: "pending") }
  scope :active, -> { pending.where("expires_at > ?", Time.current) }
  scope :expired, -> { pending.where("expires_at <= ?", Time.current) }

  def expired?
    pending? && expires_at <= Time.current
  end

  def pending?
    status == "pending"
  end

  def accepted?
    status == "accepted"
  end

  def can_be_accepted?
    pending? && !expired?
  end

  def accept!(user)
    raise "Invite cannot be accepted" unless can_be_accepted?

    # Check if user is already in a different family
    if user.family_id.present? && user.family_id != family_id
      raise "User is already in a different family"
    end

    transaction do
      # Only update family if not already set to this family
      if user.family_id != family_id
        user.update!(family: family, role: "parent")
      end

      update!(
        status: "accepted",
        accepted_by: user,
        accepted_at: Time.current
      )
    end
  end

  def cancel!
    raise "Only pending invites can be cancelled" unless pending?
    update!(status: "cancelled")
  end

  private

  def generate_token
    self.token ||= loop do
      token = SecureRandom.urlsafe_base64(32)
      break token unless Invite.exists?(token: token)
    end
  end

  def set_expiration
    self.expires_at ||= 7.days.from_now
  end

  def invited_by_must_be_parent
    if invited_by && !invited_by.parent?
      errors.add(:invited_by, "must be a parent")
    end
  end
end
