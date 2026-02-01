class PrizesController < ApplicationController
  before_action :authenticate_user!

  def index
    @prizes = current_user.family.prizes.active.by_cost
  end

  def show
    @prize = current_user.family.prizes.active.find(params[:id])
    @can_afford = current_user.can_afford?(@prize)
    @points_needed = @prize.point_cost - current_user.available_points
  end
end
