class Admin::GroupsController < Admin::BaseController
  before_action :set_group, only: [:show, :edit, :update, :destroy, :add_member, :remove_member]

  def index
    @groups = current_family.groups.includes(:users)
  end

  def show
    @available_kids = current_family.kids.where.not(id: @group.user_ids)
  end

  def new
    @group = current_family.groups.build
  end

  def create
    @group = current_family.groups.build(group_params)
    if @group.save
      redirect_to admin_group_path(@group), notice: "Group created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to admin_group_path(@group), notice: "Group updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to admin_groups_path, notice: "Group deleted successfully."
  end

  def add_member
    user = current_family.kids.find(params[:user_id])
    @group.add_member(user)
    redirect_to admin_group_path(@group), notice: "#{user.name} added to group."
  end

  def remove_member
    user = @group.users.find(params[:user_id])
    @group.remove_member(user)
    redirect_to admin_group_path(@group), notice: "#{user.name} removed from group."
  end

  private

  def set_group
    @group = current_family.groups.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :description)
  end
end
