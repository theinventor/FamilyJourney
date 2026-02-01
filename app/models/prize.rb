class Prize < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :family
  has_many :redemptions, dependent: :destroy

  has_one_attached :image

  validates :name, presence: true
  validates :point_cost, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :by_cost, -> { order(point_cost: :asc) }

  # Broadcast when prize changes
  after_create_commit :broadcast_prize_change
  after_update_commit :broadcast_prize_change
  after_destroy_commit :broadcast_prize_change

  private

  def broadcast_prize_change
    broadcast_refresh_to family, "prizes_admin"
    broadcast_refresh_to family, "prizes_kid" if active?
  end
end
