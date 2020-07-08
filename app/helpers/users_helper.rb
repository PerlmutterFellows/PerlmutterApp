module UsersHelper

  def get_full_name(user)
    [user.first_name, user.last_name].join(' ')
  end

  def get_user_role_info(user)
    if admin_signed_in?(user)
      fa_user_icon = 'fa fa-user-cog'
      fa_icon = 'fa fa-cogs'
      account_type = I18n.t("global.menu.admin")
    elsif moderator_signed_in?(user)
      fa_user_icon = 'fa fa-user-edit'
      fa_icon = 'fa fa-edit'
      account_type = I18n.t("global.menu.moderator")
    elsif !user.blank?
      fa_user_icon = 'fa fa-user'
      fa_icon = fa_user_icon
      account_type = I18n.t("global.user")
    else
      fa_user_icon = 'fa fa-user-secret'
      fa_icon = fa_user_icon
      account_type = I18n.t("global.menu.guest")
    end
    [fa_user_icon, fa_icon, account_type]
  end

  def get_user_html_header(user)
    fa_user_icon, fa_icon, account_type = get_user_role_info(user)
    TextHandler.new.process_fa(fa_user_icon, nil, "<span>#{account_type}</span>", nil).html_safe
  end

  def get_user_html_body(user, status)

    "#{!user.phone_number.blank? ?
           "<p class='card-text'>#{TextHandler.new.process_fa("fa fa-phone-square", nil, user.phone_number, nil)}</p>" :
           ""}
    #{ !user.email.blank? ?
           "<p class='card-text'>#{TextHandler.new.process_fa("fa fa-envelope-square", nil, user.email, nil)}</p>" :
           ""}
    #{ !status.blank? ?
           "<p class='card-text'>#{t(:".global.#{status.state}")}</p>" :
           "" }".html_safe
  end

  def get_user_html_buttons(user, is_on_show)

    if is_on_show
      tertiary_button = "#{link_to I18n.t("global.back"), :back, class: "btn btn-outline-primary"}"
    else
      tertiary_button = "#{link_to I18n.t("global.show"), users_show_path(user), class: "btn btn-outline-primary"}"
    end
    "<div class='text-center'>
      <div class='btn-group btn-group-md' role='group'>
        #{link_to I18n.t("global.delete"), users_delete_path(user), class: "btn btn-outline-primary", method: :delete, data: { confirm: I18n.t("global.are_you_sure") }}
        #{link_to I18n.t("global.edit"), "#", class: "btn btn-outline-primary"}
        #{tertiary_button}
      </div>
    </div>".html_safe
  end

  def destroy_user(user, redirect_path)
    respond_to do |format|
      user.destroy
      flash['success'] = t('global.model_deleted', type: t('global.user').downcase)
      format.html { redirect_to redirect_path }
    end
  end
end
