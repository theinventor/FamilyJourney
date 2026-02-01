class InvitesController < ApplicationController
  before_action :load_invite, only: [:show, :accept]

  def show
    if @invite.expired?
      render :expired
    elsif @invite.accepted?
      render :already_accepted
    elsif user_signed_in?
      # User is already logged in, show accept page
      render :show
    else
      # User is not logged in, redirect to signup with invite token
      redirect_to new_user_registration_path(invite_token: @invite.token)
    end
  end

  def accept
    if !user_signed_in?
      redirect_to new_user_registration_path(invite_token: @invite.token), alert: "Please sign in or create an account to accept the invite."
      return
    end

    if current_user.family_id.present? && current_user.family_id != @invite.family_id
      redirect_to dashboard_path, alert: "You are already in a different family."
      return
    end

    if current_user.family_id == @invite.family_id
      redirect_to dashboard_path, notice: "You are already a member of this family."
      return
    end

    @invite.accept!(current_user)
    redirect_to dashboard_path, notice: "Welcome to #{@invite.family.name}! You are now a parent in this family."
  rescue StandardError => e
    redirect_to invite_path(@invite.token), alert: "Failed to accept invite: #{e.message}"
  end

  private

  def load_invite
    @invite = Invite.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Invalid invite link."
  end
end
