class Group < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :family
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships
  has_many :badge_assignments, dependent: :destroy
  has_many :badges, through: :badge_assignments

  validates :name, presence: true

  after_create_commit :broadcast_group_change
  after_update_commit :broadcast_group_change
  after_destroy_commit :broadcast_group_change

  def member?(user)
    users.include?(user)
  end

  def add_member(user)
    users << user unless member?(user)
  end

  def remove_member(user)
    users.delete(user)
  end

  private

  def broadcast_group_change
    broadcast_refresh_to family, "groups_admin"
    broadcast_refresh_to family, "parent_dashboard"
  end
end
