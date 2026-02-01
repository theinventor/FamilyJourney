class Admin::InvitesController < Admin::BaseController
  def index
    @invites = current_family.invites.order(created_at: :desc)
    @active_invites = @invites.active
    @expired_invites = @invites.expired
  end

  def new
    @invite = current_family.invites.new
  end

  def create
    @invite = current_family.invites.new(invite_params)
    @invite.invited_by = current_user

    if @invite.save
      NotificationMailer.parent_invited(@invite).deliver_later if @invite.email.present?
      redirect_to admin_invites_path, notice: "Invite created successfully. #{@invite.email.present? ? 'Email sent!' : 'Share the link to invite another parent.'}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @invite = current_family.invites.find(params[:id])
    @invite.cancel!
    redirect_to admin_invites_path, notice: "Invite cancelled successfully."
  rescue StandardError => e
    redirect_to admin_invites_path, alert: "Failed to cancel invite: #{e.message}"
  end

  private

  def invite_params
    params.require(:invite).permit(:email)
  end
end
