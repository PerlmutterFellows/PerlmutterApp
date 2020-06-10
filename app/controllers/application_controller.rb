class ApplicationController < ActionController::Base
  include RegistrationsHelper
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    added_attrs = [:username, :first_name, :last_name, :email, :phone_number, :password, :password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def authenticate_user!
    unless user_signed_in?
      flash[:error] = "You must be signed in to view this page!"
      redirect_to root_path
    end
  end

  def admin_signed_in?
    user_signed_in? && current_user.admin
  end

  def authenticate_admin!
    unless admin_signed_in?
      flash[:error] = "You must be an admin to view this page!"
      redirect_to root_path
    end
  end
end
