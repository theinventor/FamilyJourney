class Admin::BadgeCategoriesController < Admin::BaseController
  before_action :set_badge_category, only: [:show, :edit, :update, :destroy, :move_up, :move_down]

  def index
    @badge_categories = current_family.badge_categories.includes(:badges)
  end

  def show
  end

  def new
    @badge_category = current_family.badge_categories.build
  end

  def create
    @badge_category = current_family.badge_categories.build(badge_category_params)
    if @badge_category.save
      redirect_to admin_badge_categories_path, notice: "Category created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @badge_category.update(badge_category_params)
      redirect_to admin_badge_categories_path, notice: "Category updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @badge_category.destroy
    redirect_to admin_badge_categories_path, notice: "Category deleted successfully."
  end

  def move_up
    @badge_category.move_up
    redirect_to admin_badge_categories_path
  end

  def move_down
    @badge_category.move_down
    redirect_to admin_badge_categories_path
  end

  private

  def set_badge_category
    @badge_category = current_family.badge_categories.find(params[:id])
  end

  def badge_category_params
    params.require(:badge_category).permit(:name)
  end
end
