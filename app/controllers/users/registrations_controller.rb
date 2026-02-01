# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :check_honeypot, only: :create

  private

  def check_honeypot
    if params[:website].present?
      # Bot detected - silently redirect to avoid giving feedback
      redirect_to root_path
    end
  end
end
