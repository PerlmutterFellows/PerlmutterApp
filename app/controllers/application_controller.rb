class ApplicationController < ActionController::Base
  include ApplicationHelper
  include RegistrationsHelper
  include EventsHelper
  include GroupsHelper
  include UsersHelper
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  private

  def default_url_options
    {locale: I18n.locale}
  end

  def set_locale
    extracted_locale = extract_locale
    if user_signed_in? && !extracted_locale.blank? && extracted_locale == current_user.get_locale
      update_locale(extracted_locale)
    end
    I18n.locale = extracted_locale || I18n.default_locale
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:username, :first_name, :last_name, :email, :phone_number, :password, :password_confirmation, :locale, :role]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
