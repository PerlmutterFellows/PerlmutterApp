module EventsHelper
  def toggle_attendance(user_id, group_id, change_state, flash_over_text)
    membership = GroupMembership.find_by(user_id: user_id, group_id: group_id)
    output = ""
    if !membership.blank?
      case change_state
      when true
        if GroupMembership.states[membership.state].to_i != 5
          membership.state = 5
          membership.save
          flash_over_text ? flash['success'] = I18n.t('events.attending_success_response') : output = I18n.t('events.attending_success_response')
        else
          flash_over_text ? flash['error'] = I18n.t('events.attending_failed_response') : output = I18n.t('events.attending_failed_response')
        end
      when false
        if GroupMembership.states[membership.state].to_i != 4
          membership.state = 4
          membership.save
          flash_over_text ? flash['success'] = I18n.t('events.not_attending_success_response') : output = I18n.t('events.not_attending_success_response')
        else
          flash_over_text ? flash['error'] = I18n.t('events.not_attending_failed_response') : output = I18n.t('events.not_attending_failed_response')
        end
      else
        flash_over_text ? flash['error'] = I18n.t('global.invalid_input') : output = I18n.t('global.invalid_input')
      end
    else
      flash_over_text ? flash['error'] = I18n.t('global.invalid_input') : output = I18n.t('global.invalid_input')
    end
    flash_over_text ? events_path : output
  end

  def get_users_state_counts(event)
    state_counts = [0, 0, 0, 0, 0, 0]
    event.group.users.each do |user|
      membership = GroupMembership.find_by(user_id: user.id, group_id: event.group.id)
      unless membership.blank?
        state_counts[GroupMembership.states[membership.state].to_i] += 1
      end
    end
    state_counts
  end

  def get_when_text(event)
    when_text = ""
    start_cond = !event.startDate.blank? || !event.startTime.blank?
    end_cond = !event.endDate.blank? || !event.endTime.blank?
    start_text = ""
    end_text = ""
    if start_cond
      if !event.startDate.blank? && !event.startTime.blank?
        start_text += "#{event.startDate.strftime("%m/%d/%Y")} #{event.startTime.strftime("%I:%M%p")}"
      elsif !event.startDate.blank? && event.startTime.blank?
        start_text += "#{event.startDate.strftime("%m/%d/%Y")}"
      elsif event.startDate.blank? && !event.startTime.blank?
        start_text += "#{event.startTime.strftime("%I:%M%p")}"
      end
    end
    if end_cond
      if !event.endDate.blank? && !event.endTime.blank?
        end_text += "#{event.endDate.strftime("%m/%d/%Y")} #{event.endTime.strftime("%I:%M%p")}"
      elsif !event.endDate.blank? && event.endTime.blank?
        end_text += "#{event.endDate.strftime("%m/%d/%Y")}"
      elsif event.endDate.blank? && !event.endTime.blank?
        end_text += "#{event.endTime.strftime("%I:%M%p")}"
      end
    end
    if start_cond && end_cond
      when_text += "#{start_text}—#{end_text}"
    else
      when_text += "#{start_text}#{end_text}"
    end
    when_text
  end

  def get_event_text_params(event, email)
    separator = (email ? "<br>" : "\n")
    "#{I18n.t("events.title")}: #{event.title}#{separator}#{I18n.t("events.description")}: #{event.description}#{separator}#{!event.location.blank? ? "#{I18n.t("events.when")}: #{get_when_text(event)}#{separator}" : ""}#{!event.location.blank? ? "#{I18n.t("events.where")}: #{event.location}#{separator}" : ""}"
  end

  def send_event_notification(event, user, membership)
    if !user.email.blank? && !user.confirmed_at.blank?
      if GroupMembership.states[membership.state].to_i < 2
        begin
          UserMailer.event_create_email(user, event).deliver
          membership.state = (Event.eventTypes[event.eventType].to_i == 0 ? 3 : 2)
        rescue StandardError => e
          puts("Send failed: #{e}")
          membership.state = 1
        end
        membership.save
      else
        begin
          UserMailer.event_update_email(user, event).deliver
        rescue StandardError => e
          puts("Send failed: #{e}")
        end
      end
    elsif !user.phone_number.blank? && !user.confirmed_at.blank?
      if GroupMembership.states[membership.state].to_i < 2
        prompt = (Event.eventTypes[event.eventType].to_i == 0 ? t('texts.new_prompt', id: event.id) : "")
        success, error = TwilioHandler.new.send_text(user, t('texts.new_event', params: get_event_text_params(event, false), type: event.eventType, prompt: prompt))
        if success
          membership.state = (Event.eventTypes[event.eventType].to_i == 0 ? 3 : 2)
        else
          membership.state = 1
        end
        membership.save
      else
        prompt = (Event.eventTypes[event.eventType].to_i == 0 ? t('texts.updated_prompt', id: event.id) : "")
        success, error = TwilioHandler.new.send_text(user, t('texts.updated_event', params: get_event_text_params(event, false), type: event.eventType.capitalize, prompt: prompt))
      end
    end
  end

  def send_delete_event_notification(event, user)
    if !user.email.blank? && !user.confirmed_at.blank?
      begin
        UserMailer.event_delete_email(user, event).deliver
      rescue StandardError => e
        puts("Send failed: #{e}")
      end
    elsif !user.phone_number.blank? && !user.confirmed_at.blank?
      success, error = TwilioHandler.new.send_text(user, t('texts.deleted_event', params: get_event_text_params(event, false), type: event.eventType.capitalize))
    end
  end

  def publish_event(event)
    event.group.users.each do |user|
      membership = GroupMembership.find_by(user_id: user.id, group_id: event.group.id)
      unless membership.blank?
        send_event_notification(event, user, membership)
      end
    end
  end

  def notify_delete_event(event)
    event.group.users.each do |user|
      membership = GroupMembership.find_by(user_id: user.id, group_id: event.group.id)
      unless membership.blank?
        send_delete_event_notification(event, user)
      end
    end
  end
end
