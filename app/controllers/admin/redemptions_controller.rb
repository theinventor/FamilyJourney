class Admin::RedemptionsController < Admin::BaseController
  before_action :set_redemption, only: [:show, :approve, :deny]

  def index
    @pending_redemptions = Redemption.pending
      .joins(:user)
      .where(users: { family_id: current_family.id })
      .includes(:prize, :user)
      .order(requested_at: :asc)

    @recent_redemptions = Redemption
      .where(status: [:approved, :denied])
      .joins(:user)
      .where(users: { family_id: current_family.id })
      .includes(:prize, :user, :reviewed_by)
      .order(reviewed_at: :desc)
      .limit(10)
  end

  def show
  end

  def approve
    if @redemption.approve!(current_user, feedback: params[:feedback])
      NotificationMailer.redemption_approved(@redemption).deliver_later if defined?(NotificationMailer) && NotificationMailer.method_defined?(:redemption_approved)
      redirect_to admin_redemptions_path, notice: "Prize approved! #{@redemption.user.name} spent #{@redemption.points_spent} points."
    else
      redirect_to admin_redemption_path(@redemption), alert: "#{@redemption.user.name} no longer has enough points for this prize."
    end
  end

  def deny
    if params[:feedback].blank?
      redirect_to admin_redemption_path(@redemption), alert: "Please provide feedback when denying a request."
      return
    end

    @redemption.deny!(current_user, feedback: params[:feedback])
    NotificationMailer.redemption_denied(@redemption).deliver_later if defined?(NotificationMailer) && NotificationMailer.method_defined?(:redemption_denied)
    redirect_to admin_redemptions_path, notice: "Request denied. Feedback sent to #{@redemption.user.name}."
  end

  private

  def set_redemption
    @redemption = Redemption
      .joins(:user)
      .where(users: { family_id: current_family.id })
      .find(params[:id])
  end
end
