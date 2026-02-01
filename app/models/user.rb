class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :family
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :badge_submissions, dependent: :destroy
  has_many :challenge_completions, dependent: :destroy
  has_many :redemptions, dependent: :destroy

  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[parent kid] }

  before_create :generate_api_token, if: :parent?

  def parent?
    role == "parent"
  end

  def kid?
    role == "kid"
  end

  def lifetime_points
    badge_submissions.approved.joins(:badge).sum("badges.points")
  end

  def spent_points
    redemptions.approved.sum(:points_spent)
  end

  def available_points
    lifetime_points - spent_points
  end

  def can_afford?(prize)
    available_points >= prize.point_cost
  end

  def regenerate_api_token!
    update!(api_token: generate_unique_token)
  end

  private

  def generate_api_token
    self.api_token = generate_unique_token
  end

  def generate_unique_token
    loop do
      token = SecureRandom.hex(32)
      break token unless User.exists?(api_token: token)
    end
  end
end
