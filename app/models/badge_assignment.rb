class BadgeAssignment < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :badge
  belongs_to :group
  belongs_to :assigned_by, class_name: "User", optional: true

  validates :badge_id, uniqueness: { scope: :group_id }

  scope :active, -> { where(active: true) }

  before_create :set_assigned_at
  after_create_commit :broadcast_assignment_change
  after_destroy_commit :broadcast_assignment_change

  def family
    badge.family
  end

  private

  def set_assigned_at
    self.assigned_at ||= Time.current
  end

  def broadcast_assignment_change
    # Badge assignments affect which kids see which badges
    broadcast_refresh_to family, "badges_admin"
    broadcast_refresh_to family, "kid_dashboards"
  end
end
