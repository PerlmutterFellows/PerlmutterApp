module GroupsHelper

  def get_group_html_header
    TextHandler.new.process_fa("fa fa-users", nil, "<span>#{I18n.t("global.group")}</span>", nil).html_safe
  end

  def get_group_html_title(group)
    "#{group.name}".html_safe
  end

  def get_group_html_body(group, is_on_show)
    users_html = ""
    if user_is_admin?
      if is_on_show
        group.users.each do |user|
          users_html += "<p class='card-text pt-2'><strong>#{get_full_name(user)}</strong></p>" + get_user_html_body(user, nil)
        end
      end
    end
    "<p class='card-text'>#{TextHandler.new.process_fa("fa fa-user-circle", nil, group.users.count.to_s, nil)} #{I18n.t("global.menu.users").downcase}</p>
    #{users_html}".html_safe
  end

  def get_group_html_buttons(group, is_on_show)
    if is_on_show
      tertiary_button = "#{link_to I18n.t("global.back"), groups_path, class: "btn btn-primary"}"
    else
      tertiary_button = "#{link_to I18n.t("global.show"), group, class: "btn btn-primary"}"
    end
    if user_is_admin?
      "#{link_to I18n.t("global.delete"), group, class: "btn btn-primary", method: :delete, data: { confirm: I18n.t("global.are_you_sure") }}
      #{link_to I18n.t("global.edit"), edit_group_path(group), class: "btn btn-primary"}
      #{tertiary_button}".html_safe
    else
      "#{tertiary_button}".html_safe
    end
  end


  ##
  # Returns unique selected users from select array containing group and user ids
  # select - an array containing user ids (no extra prefix), and group ids (prefixed with 'g' to distinguish)
  def get_users_from_select(select)
    select = select.reject { |id| id.blank? }
    users = []
    select.each do |user_id|
      user = User.find_by_id(user_id)
      group = Group.find_by_id(user_id.sub! "g","")
      if !user.blank?
        users.push(user)
      elsif !group.blank?
        users = (users + get_users_from_select(group.users.map { |user| user.id.to_s }))
      end
    end
    users.uniq { |user| user.id }
  end

  ##
  # Returns a modified version of provided users where a user already in the group does not get overwritten, maintaining its values
  # users - an array of users
  # group - a group containing users
  def maintain_state(users, group)
    users.each do |user|
      if group.users.exists?(user.id)
        user = group.users.find(user.id)
        user.save
      end
    end
    users
  end
end
