class ApiDocsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_parent!

  def show
    # Documentation is rendered in the view
  end

  private

  def require_parent!
    unless current_user.parent?
      redirect_to dashboard_path, alert: "API documentation is only available to parents."
    end
  end
end
