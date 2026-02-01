# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def create
    # Store invite token before signing in
    @invite_token = params[:invite_token]
    super
  end

  protected

  def after_sign_in_path_for(resource)
    if @invite_token.present?
      invite = Invite.find_by(token: @invite_token)
      if invite&.can_be_accepted?
        return invite_path(@invite_token)
      end
    end
    super
  end
end
