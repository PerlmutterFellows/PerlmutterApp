class ApplicationController < ActionController::Base
  include RegistrationsHelper
  include UsersHelper
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  private

  def default_url_options
    {locale: I18n.locale}
  end

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    parsed_locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale.to_sym : nil
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:username, :first_name, :last_name, :email, :phone_number, :password, :password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def authenticate_user!
    unless user_signed_in?
      flash[:error] = t('global.warning', type: 'user')
      redirect_to root_path
    end
  end

  def admin_signed_in?
    user_signed_in? && current_user.admin
  end

  def authenticate_admin!
    unless admin_signed_in?
      flash[:error] = t('global.warning', type: 'admin')
      redirect_to root_path
    end
  end
end
