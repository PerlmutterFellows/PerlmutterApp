module ApplicationHelper

  def get_host_url
    require 'ngrok/tunnel'
    url = ""
    url_options = Rails.configuration.action_mailer.default_url_options
    unless url_options.blank?
      url = url_options.values.compact.join(":")
    end
    url
  end

  def moderator_signed_in?(user)
    user_signed_in? && !user.blank? && (user.moderator? || user.admin?)
  end

  def admin_signed_in?(user)
    user_signed_in? && !user.blank? && user.admin?
  end

  def authenticate!(condition, role)
    unless condition
      flash.now.alert = t('global.warning', type: role)
      redirect_to root_path
    end
  end

  def authenticate_user!
    authenticate!(user_signed_in?, t('global.user').downcase)
  end

  def authenticate_moderator!
    authenticate!((moderator_signed_in?(current_user) || admin_signed_in?(current_user)), t('global.menu.moderator').downcase)
  end

  def authenticate_admin!
    authenticate!(admin_signed_in?(current_user), t('global.menu.admin').downcase)
  end

  def toastr_flash
    flash.each_with_object([]) do |(type, message), flash_messages|
      type = 'success' if type == 'notice'
      type = 'error' if type == 'alert'
      text = "<script>toastr.#{type}('#{message}', '', { closeButton: true, progressBar: true, positionClass: 'toast-top-center mt-5'})</script>"
      flash_messages << text.html_safe if message
    end.join("\n").html_safe
  end

  def emojify(content)
    h(content).to_str.gsub(/:([\w+-]+):/) do |match|
      if emoji = Emoji.find_by_alias($1)
        %(<img alt="#$1" src="#{image_path("emoji/#{emoji.image_filename}")}" style="vertical-align:middle" width="20" height="20" />)
      else
        match
      end
    end.html_safe if content.present?
  end

  def yield_locale_from_available(locale)
    if locale.instance_of? Symbol
      locale = locale.to_s
    end
    I18n.available_locales.map(&:to_s).include?(locale) ? locale.to_sym : nil
  end

  def update_locale(locale)
    if user_signed_in?
      locale = locale.blank? ? I18n.locale : locale
      current_user.locale = locale
      current_user.save
    end
  end

  def extract_locale
    parsed_locale = params[:locale]
    yield_locale_from_available(parsed_locale)
  end

end
