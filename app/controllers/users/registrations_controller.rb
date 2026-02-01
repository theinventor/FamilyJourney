# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :check_honeypot, only: :create

  def create
    # Create family first
    @family = Family.new(name: params[:family_name])

    if @family.save
      # Build the user with the family
      build_resource(sign_up_params.merge(family: @family, role: "parent"))

      if resource.save
        yield resource if block_given?
        if resource.persisted?
          if resource.active_for_authentication?
            set_flash_message! :notice, :signed_up
            sign_up(resource_name, resource)
            respond_with resource, location: after_sign_up_path_for(resource)
          else
            set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
            expire_data_after_sign_in!
            respond_with resource, location: after_inactive_sign_up_path_for(resource)
          end
        else
          clean_up_passwords resource
          set_minimum_password_length
          @family.destroy # Clean up the family if user creation failed
          respond_with resource
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        @family.destroy # Clean up the family if user creation failed
        respond_with resource
      end
    else
      # Family validation failed
      build_resource(sign_up_params)
      resource.errors.add(:base, "Family name #{@family.errors.full_messages.join(', ')}")
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  private

  def check_honeypot
    if params[:website].present?
      # Bot detected - silently redirect to avoid giving feedback
      redirect_to root_path
    end
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end
end
