class Family < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :badge_categories, dependent: :destroy
  has_many :badges, dependent: :destroy
  has_many :prizes, dependent: :destroy

  validates :name, presence: true

  def parents
    users.where(role: "parent")
  end

  def kids
    users.where(role: "kid")
  end
end
