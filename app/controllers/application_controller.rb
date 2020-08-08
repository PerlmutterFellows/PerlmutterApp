class ApplicationController < ActionController::Base
  include ApplicationHelper
  include RegistrationsHelper
  include EventsHelper
  include GroupsHelper
  include UsersHelper
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :set_admin_user

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

  def set_admin_user
    user = User.find_by(email: I18n.t("config.admin.email"))
    if user.blank?
      user = User.new(first_name: I18n.t("config.admin.first_name"),
                      last_name: I18n.t("config.admin.last_name"),
                      email: I18n.t("config.admin.email"),
                      password: I18n.t("config.admin.password"),
                      password_confirmation: I18n.t("config.admin.password"),
                      role: 2,
                      locale: "en",
                      use_email: true)
      user.skip_confirmation!
      user.save
    end
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:username, :first_name, :last_name, :email, :phone_number, :password, :password_confirmation, :locale, :role, :use_email, :use_text, :use_call]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
