module UsersHelper
  def user_is_admin?
    current_user && current_user.admin
  end

  def get_full_name(user)
    [user.first_name, user.last_name].join(' ')
  end

  def get_user_html_header(user)
    if user.admin
      fa_icon = 'fa fa-user-secret'
      account_type = I18n.t("global.menu.admin")
    else
      fa_icon = 'fa fa-user'
      account_type = I18n.t("global.user")
    end
    TextHandler.new.process_fa(fa_icon, nil, "<span>#{account_type}</span>", nil).html_safe
  end

  def get_user_html_body(user, membership)

    "#{!user.phone_number.blank? ?
           "<p class='card-text'>#{TextHandler.new.process_fa("fa fa-phone-square", nil, user.phone_number, nil)}</p>" :
           ""}
    #{ !user.email.blank? ?
           "<p class='card-text'>#{TextHandler.new.process_fa("fa fa-envelope-square", nil, user.email, nil)}</p>" :
           ""}
    #{ !membership.blank? ?
           "<p class='card-text'>#{t(:".global.#{membership.state}")}</p>" :
           "" }".html_safe
  end

  def get_user_html_buttons(user, is_on_show)
    if is_on_show
      tertiary_button = "#{link_to I18n.t("global.back"), users_path, class: "btn btn-primary"}"
    else
      tertiary_button = "#{link_to I18n.t("global.show"), users_show_path(user), class: "btn btn-primary"}"
    end
    "#{link_to I18n.t("global.delete"), users_delete_path(user), class: "btn btn-primary", method: :delete, data: { confirm: I18n.t("global.are_you_sure") }}
    #{link_to I18n.t("global.edit"), "#", class: "btn btn-primary"}
    #{tertiary_button}".html_safe
  end

  def destroy_user(user, redirect_path)
    respond_to do |format|
      user.destroy
      flash['success'] = t('global.model_deleted', type: t('global.user').downcase)
      format.html { redirect_to redirect_path }
    end
  end
end
