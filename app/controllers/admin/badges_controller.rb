class Admin::BadgesController < Admin::BaseController
  before_action :set_badge, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

  def index
    @badges = current_family.badges.includes(:badge_category, :groups).order(:title)
  end

  def show
  end

  def new
    @badge = current_family.badges.build(points: 10)
  end

  def create
    @badge = current_family.badges.build(badge_params)
    @badge.created_by = current_user
    if @badge.save
      redirect_to admin_badge_path(@badge), notice: "Badge created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @badge.update(badge_params)
      redirect_to admin_badge_path(@badge), notice: "Badge updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @badge.destroy
    redirect_to admin_badges_path, notice: "Badge deleted successfully."
  end

  def publish
    @badge.publish!
    redirect_to admin_badge_path(@badge), notice: "Badge published successfully."
  end

  def unpublish
    @badge.unpublish!
    redirect_to admin_badge_path(@badge), notice: "Badge unpublished successfully."
  end

  private

  def set_badge
    @badge = current_family.badges.find(params[:id])
  end

  def badge_params
    params.require(:badge).permit(
      :title, :description, :instructions, :points, :badge_category_id,
      group_ids: [],
      badge_challenges_attributes: [:id, :title, :description, :position, :_destroy]
    )
  end
end
