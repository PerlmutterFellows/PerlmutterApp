module GroupsHelper

  def get_group_html_header
    TextHandler.new.process_fa("fa fa-users", nil, "<span>#{I18n.t("global.group")}</span>", nil).html_safe
  end

  def get_group_html_title(group)
    "#{group.name}".html_safe
  end

  def get_group_html_body(group, is_on_show)
    users_html = ""
    if moderator_signed_in?(current_user)
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
      tertiary_button = "#{link_to I18n.t("global.back"), :back, class: "btn btn-outline-primary"}"
    else
      tertiary_button = "#{link_to I18n.t("global.show"), group, class: "btn btn-outline-primary"}"
    end
    button_html = "<div class='text-center'>
                    <div class='btn-group btn-group-md' role='group'>"
    if moderator_signed_in?(current_user)
      button_html += "#{link_to I18n.t("global.delete"), group, class: "btn btn-outline-primary", method: :delete, data: { confirm: I18n.t("global.are_you_sure") }}
                      #{link_to I18n.t("global.edit"), edit_group_path(group), class: "btn btn-outline-primary"}
                      #{tertiary_button}
                    </div>
                  </div>"
    else
      button_html += "#{tertiary_button}
                    </div>
                  </div>"
    end
    button_html.html_safe
  end

  def reset_filters
    queries = [:user_name_query, :group_name_query]
    queries.each { |query| session[query] = nil }
  end

  ##
  # Returns unique selected users from select array containing group and user ids
  # select - an array containing user ids (no extra prefix), and group ids (prefixed with 'g' to distinguish)
  def get_users_from_select(select)
    select = select.reject { |id| id.blank? }
    unless select.blank?
      group_ids = select.select {|group_id| group_id.start_with?("g")}
      users = User.find(select - group_ids)
      group_users = group_ids.map {|group_id| group_id.sub! "g",""}
                        .map {|group_id| Group.find(group_id).users}
                        .flatten
      group_users.concat(users).uniq
    end
  end

  ##
  # Updates the users tied to an event
  # users - an array of users
  # event - an event containing the original users
  #
  def update_event_users(users, event)
    deleted_users = event.users - users
    deleted_users.each do |user|
      EventStatus.find_by(user_id: user.id, event_id: event.id).delete
    end
    users.each do |user|
      if EventStatus.find_by(user_id: user.id, event_id: event.id).blank?
        event.users << user
      end
    end
  end


  def get_select_vals(is_for_event)
    select_group_vals = []

    if is_for_event
      Group.all.each do |group|
        val_label = group.name

        if !group.blank? && !group.users.blank?
          val_label += " <span class='badge'><i class='fa fa-user-circle' aria-hidden='true'></i> #{group.users.count} users</span>"

          if group.users.count > 0
            select_group_vals.push([val_label, "g" + group.id.to_s])
          end
        end
      end
    end

    select_user_vals = []
    id_vals = []

    User.all.select {|user| !moderator_signed_in?(user)}.each do |user|
      val_label = get_full_name(user)

      unless user.phone_number.blank?
        val_label += " <span class='badge'><i class='fa fa-phone-square' aria-hidden='true'></i> #{user.phone_number}</span>"
      end

      unless user.email.blank?
        val_label += " <span class='badge'><i class='fa fa-envelope-square' aria-hidden='true'></i> #{user.email}</span>"
      end

      select_user_vals.push([val_label, user.id.to_s])
      id_vals.push(user.id.to_s)
    end

    selected_vals = []

    if is_for_event

      unless @event.blank?
        @event.users.each do |user|

          if id_vals.include? user.id.to_s
            selected_vals.push(user.id.to_s)
          end
        end
      end
    else
      @group.users.each do |user|
        if id_vals.include? user.id.to_s
          selected_vals.push(user.id.to_s)
        end
      end
    end

    select_group_vals.sort_by!{ |u| u }
    select_user_vals.sort_by!{ |u| u }
    select_vals = select_group_vals.concat(select_user_vals)

    [select_vals, selected_vals]
  end
end
