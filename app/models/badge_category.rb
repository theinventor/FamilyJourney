class BadgeCategory < ApplicationRecord
  belongs_to :family
  has_many :badges, dependent: :nullify

  validates :name, presence: true

  default_scope { order(position: :asc) }

  before_create :set_position

  def move_up
    return if position <= 1
    swap_with = family.badge_categories.unscoped.find_by(position: position - 1, family: family)
    return unless swap_with
    swap_positions(swap_with)
  end

  def move_down
    swap_with = family.badge_categories.unscoped.find_by(position: position + 1, family: family)
    return unless swap_with
    swap_positions(swap_with)
  end

  private

  def set_position
    max_position = family.badge_categories.unscoped.maximum(:position) || 0
    self.position = max_position + 1
  end

  def swap_positions(other)
    self.class.transaction do
      temp = position
      update!(position: other.position)
      other.update!(position: temp)
    end
  end
end
