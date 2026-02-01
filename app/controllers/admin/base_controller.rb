class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_parent!

  private

  def require_parent!
    unless current_user.parent?
      redirect_to dashboard_path, alert: "You don't have permission to access this area."
    end
  end

  def current_family
    current_user.family
  end
  helper_method :current_family
end
