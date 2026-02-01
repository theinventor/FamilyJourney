class Prize < ApplicationRecord
  belongs_to :family
  has_many :redemptions, dependent: :destroy

  has_one_attached :image

  validates :name, presence: true
  validates :point_cost, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :by_cost, -> { order(point_cost: :asc) }
end
