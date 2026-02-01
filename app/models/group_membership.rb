class GroupMembership < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :group
  belongs_to :user

  validates :user_id, uniqueness: { scope: :group_id, message: "is already a member of this group" }

  after_create_commit :broadcast_membership_change
  after_destroy_commit :broadcast_membership_change

  def family
    group.family
  end

  private

  def broadcast_membership_change
    # Kid's available badges may have changed
    broadcast_refresh_to family, "kid_dashboard_#{user_id}"
    # Parent dashboard may need update
    broadcast_refresh_to family, "parent_dashboard"
    broadcast_refresh_to family, "groups_admin"
  end
end
