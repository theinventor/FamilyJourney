class Group < ApplicationRecord
  belongs_to :family
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships
  has_many :badge_assignments, dependent: :destroy
  has_many :badges, through: :badge_assignments

  validates :name, presence: true

  def member?(user)
    users.include?(user)
  end

  def add_member(user)
    users << user unless member?(user)
  end

  def remove_member(user)
    users.delete(user)
  end
end
