class Admin::KidsController < Admin::BaseController
  before_action :set_kid, only: [ :show, :edit, :update, :destroy, :reset_password ]

  def index
    @kids = current_family.kids.order(:name)
  end

  def show
  end

  def new
    @kid = User.new
  end

  def create
    # Generate a random password for the kid
    temp_password = SecureRandom.hex(4) # 8 character password

    @kid = User.new(kid_params)
    @kid.family = current_family
    @kid.role = "kid"
    @kid.password = temp_password
    @kid.password_confirmation = temp_password

    if @kid.save
      # Store the temp password in flash to show the parent
      redirect_to admin_kid_path(@kid), notice: "#{@kid.name} added successfully! Their temporary password is: #{temp_password}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @kid.update(kid_params)
      redirect_to admin_kid_path(@kid), notice: "#{@kid.name} updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @kid.name
    @kid.destroy
    redirect_to admin_kids_path, notice: "#{name} removed from family."
  end

  def reset_password
    temp_password = SecureRandom.hex(4)
    @kid.update(password: temp_password, password_confirmation: temp_password)
    redirect_to admin_kid_path(@kid), notice: "Password reset! New temporary password: #{temp_password}"
  end

  private

  def set_kid
    @kid = current_family.kids.find(params[:id])
  end

  def kid_params
    params.require(:user).permit(:name, :email)
  end
end
