class BadgeAssignment < ApplicationRecord
  belongs_to :badge
  belongs_to :group
  belongs_to :assigned_by, class_name: "User", optional: true

  validates :badge_id, uniqueness: { scope: :group_id }

  scope :active, -> { where(active: true) }

  before_create :set_assigned_at

  private

  def set_assigned_at
    self.assigned_at ||= Time.current
  end
end
