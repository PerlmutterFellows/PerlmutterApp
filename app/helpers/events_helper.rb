module EventsHelper
  ##
  # Toggles attendance of a given user in a group
  # user_id - a user id
  # group_id - a group id
  # attend - whether to mark the user attending or not attending
  # output_as_flash - whether to output response as a flash or as text to be parsed by Twilio
  def toggle_attendance(user_id, group_id, attend, output_as_flash)
    membership = GroupMembership.find_by(user_id: user_id, group_id: group_id)
    text_output = ""
    if !membership.blank?
      if attend
        if !membership.attending?
          membership.attending!
          output_as_flash ? flash['success'] = I18n.t('events.attending_success_response') : text_output = I18n.t('events.attending_success_response')
        else
          output_as_flash ? flash['error'] = I18n.t('events.attending_failed_response') : text_output = I18n.t('events.attending_failed_response')
        end
      else
        if !membership.not_attending?
          membership.not_attending!
          output_as_flash ? flash['success'] = I18n.t('events.not_attending_success_response') : text_output = I18n.t('events.not_attending_success_response')
        else
          output_as_flash ? flash['error'] = I18n.t('events.not_attending_failed_response') : text_output = I18n.t('events.not_attending_failed_response')
        end
      end
    else
      output_as_flash ? flash['error'] = I18n.t('global.invalid_input') : text_output = I18n.t('global.invalid_input')
    end
    output_as_flash ? events_path : text_output
  end

  ##
  # Returns an array mapping the number of users of an event to attending state
  # event - an event
  def get_attending_counts(event)
    attending_count = 0
    event.group.users.each do |user|
      membership = GroupMembership.find_by(user_id: user.id, group_id: event.group.id)
      if !membership.blank? && membership.attending?
          attending_count += 1
      end
    end
      attending_count
  end

  ##
  # Returns a parsed timeframe given an event
  # event - an event
  def get_when_text(event)
    start_text = DateService.new.convert_to_readable_date_time(event.startDate, event.startTime)
    end_text = DateService.new.convert_to_readable_date_time(event.endDate, event.endTime)
    if !start_text.blank? && !end_text.blank?
      "#{start_text}—#{end_text}"
    else
      "#{start_text}#{end_text}"
    end
  end

  ##
  # Returns a parsed payload of an event as text, separated by the proper separator for the contact method
  # event - an event
  # uses_email - whether this result will be sent in email or a text
  def get_event_text_params(event, uses_email)
    separator = (uses_email ? "<br>" : "\n")
    title_text = "#{I18n.t("events.title")}: #{event.title}#{separator}"
    description_text = "#{I18n.t("events.description")}: #{event.description}#{separator}"
    when_text = ""
    where_text = ""
    unless get_when_text(event).blank?
      when_text = "#{I18n.t("events.when")}: #{get_when_text(event)}#{separator}"
    end
    unless event.location.blank?
      where_text = "#{I18n.t("events.where")}: #{event.location}#{separator}"
    end
    "#{title_text}"\
    "#{description_text}"\
    "#{when_text}"\
    "#{where_text}"
  end

  ##
  # Sets delivery/acceptance state of a user given notification success
  # was_successful - whether notifying the user succeeded
  # event - an event
  # membership - a membership
  def set_new_state_after_notify(was_successful, event, membership)
    if was_successful
      if event.event?
        membership.not_responded!
      else
        membership.delivered!
      end
    else
      membership.not_delivered!
    end
    membership.save
  end

  ##
  # Sends notification of an event to a given user to the proper contact method, updating their state
  # event - an event
  # user - a user
  # membership - a membership
  # uses_email - whether this result will be sent in email or a text
  def handle_send_publish_event_notification(event, user, membership, uses_email)
    # If a new contact, send as new event and update their state
    if membership.non_message? || membership.not_delivered?
      if uses_email
        begin
          UserMailer.event_create_email(user, event).deliver
          set_new_state_after_notify(true, event, membership)
        rescue StandardError => e
          set_new_state_after_notify(false, event, membership)
        end
      else
        prompt = (event.event? ? t('texts.new_prompt', id: event.id) : "")
        success, error = TwilioHandler.new.send_text(user, t('texts.new_event', params: get_event_text_params(event, false), type: event.eventType, prompt: prompt))
        set_new_state_after_notify(success, event, membership)
      end
      # Otherwise, they aren't new, don't update their state, send as updated event
    else
      if uses_email
        UserMailer.event_update_email(user, event).deliver rescue user
      else
        prompt = (event.event? ? t('texts.updated_prompt', id: event.id) : "")
        success, error = TwilioHandler.new.send_text(user, t('texts.updated_event', params: get_event_text_params(event, false), type: event.eventType.capitalize, prompt: prompt))
      end
    end
  end

  ##
  # Kicks off the notification of an event to a given user, updating their state
  # event - an event
  # user - a user
  # membership - a membership
  def send_publish_event_notification(event, user, membership)
    if user.confirmed_at.blank?
      membership.not_delivered!
    elsif !user.email.blank?
      handle_send_publish_event_notification(event, user, membership, true)
    else
      handle_send_publish_event_notification(event, user, membership, false)
    end
  end

  ##
  # Sends notification of a deleted event to a given user
  # event - an event
  # user - a user
  def send_delete_event_notification(event, user)
    if !user.email.blank? && !user.confirmed_at.blank?
      UserMailer.event_delete_email(user, event).deliver rescue user
    elsif !user.phone_number.blank? && !user.confirmed_at.blank?
      success, error = TwilioHandler.new.send_text(user, t('texts.deleted_event', params: get_event_text_params(event, false), type: event.eventType.capitalize))
    end
  end

  ##
  # Calls for notification of an event, either new/update if publishing and deletion otherwise
  # event - an event
  # is_being_published - whether the event is being published or not
  def handle_notify_event(event, is_being_published)
    event.group.users.each do |user|
      membership = GroupMembership.find_by(user_id: user.id, group_id: event.group.id)
      unless membership.blank?
        if is_being_published
          send_publish_event_notification(event, user, membership)
        else
          send_delete_event_notification(event, user)
        end
      end
    end
  end

  ##
  # Returns the prefix for the event action
  # is_being_updated - whether the event is being updated or not
  # is_being_deleted - whether the event is being deleted or not
  def get_event_action_prefix(is_being_updated, is_being_deleted)
    if is_being_deleted
      I18n.t("global.deleted")
    else
      if is_being_updated
        I18n.t("global.updated")
      else
        I18n.t("global.new")
      end
    end
  end
end
