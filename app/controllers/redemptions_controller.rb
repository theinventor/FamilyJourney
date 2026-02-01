class RedemptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_kid!, except: [ :index, :show ]
  before_action :set_prize, only: [ :new, :create ]

  def index
    @redemptions = current_user.redemptions.includes(:prize).order(created_at: :desc)
  end

  def show
    @redemption = current_user.redemptions.find(params[:id])
  end

  def new
    unless current_user.can_afford?(@prize)
      redirect_to prize_path(@prize), alert: "You don't have enough points for this prize."
      return
    end

    @redemption = Redemption.new
  end

  def create
    @redemption = Redemption.new(redemption_params)
    @redemption.prize = @prize
    @redemption.user = current_user

    if @redemption.save
      NotificationMailer.redemption_requested(@redemption).deliver_later if defined?(NotificationMailer) && NotificationMailer.method_defined?(:redemption_requested)
      redirect_to redemption_path(@redemption), notice: "Prize request submitted!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def require_kid!
    unless current_user.kid?
      redirect_to dashboard_path, alert: "Only kids can request prizes."
    end
  end

  def set_prize
    @prize = current_user.family.prizes.active.find(params[:prize_id])
  end

  def redemption_params
    params.require(:redemption).permit(:kid_note)
  end
end
