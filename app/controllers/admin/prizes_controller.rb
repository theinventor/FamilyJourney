class Admin::PrizesController < Admin::BaseController
  before_action :set_prize, only: [:show, :edit, :update, :destroy]

  def index
    @prizes = current_family.prizes.order(active: :desc, point_cost: :asc)
  end

  def show
  end

  def new
    @prize = current_family.prizes.build(point_cost: 100)
  end

  def create
    @prize = current_family.prizes.build(prize_params)
    if @prize.save
      redirect_to admin_prizes_path, notice: "Prize created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @prize.update(prize_params)
      redirect_to admin_prizes_path, notice: "Prize updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @prize.destroy
    redirect_to admin_prizes_path, notice: "Prize deleted successfully."
  end

  private

  def set_prize
    @prize = current_family.prizes.find(params[:id])
  end

  def prize_params
    params.require(:prize).permit(:name, :description, :point_cost, :active, :image)
  end
end
