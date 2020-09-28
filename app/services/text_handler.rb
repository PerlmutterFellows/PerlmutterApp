class TextHandler
  include EventsHelper
  include StaticPagesHelper

  def process_input(user, input, is_text)
    if user.blank?
      I18n.t('texts.input_user_failed')
    else
      if is_text
        yes = I18n.t('texts.text_yes')
        no = I18n.t('texts.text_no')
        is_confirmed = user.confirmed_text?
        contact_method = I18n.t("global.text").downcase
      else
        yes = I18n.t('texts.call_yes')
        no = I18n.t('texts.call_no')
        is_confirmed = user.confirmed_call?
        contact_method = I18n.t("global.call").downcase
      end
      case input
      when yes
        if !is_confirmed
          is_text ? user.text_confirmed_at = DateTime.now : user.call_confirmed_at = DateTime.now
          user.save
          I18n.t('texts.confirmation_success_response', method: contact_method)
        else
          I18n.t('texts.confirmation_failed_response', method: contact_method)
        end
      when no
        if !is_confirmed
          I18n.t('texts.stop_failed_response', method: contact_method)
        else
          is_text ? user.text_confirmed_at = nil : user.call_confirmed_at = nil
          user.save
          I18n.t('texts.stop_success_response', method: contact_method)
        end
      else
        process_rsvp(user, input, yes, no)
      end
    end
  end

  def process_rsvp(user, input, yes, no)
    output = I18n.t('global.invalid_input')
    if input.length > 1
      event_id = input[0...-1] # Gets all but the last character, which is the attendance_case
      attendance_case = input[-1] # Gets the last character, the attendance_case
      event = Event.find_by_id(event_id)
      unless event.blank?
        case attendance_case
        when yes
          output = toggle_attendance(user.id, event.id, true, false)
        when no
          output = toggle_attendance(user.id, event.id, false, false)
        else
          output = I18n.t('global.invalid_input')
        end
      end
    end
    output
  end

  def process_fa(icon, body, post_body, url)
    output = "<i class='#{icon} fa-lg mr-2' aria-hidden='true'>#{!body.blank? ? body : ""}</i>"
    unless post_body.blank?
      output += post_body
    end
    unless url.blank?
      output = "<a href='#{url}'>#{output}</a>"
    end
    output
  end

  def process_faqs()
    faqs = ""
    if faq_configured?
      faqs += "<div id='accordion'>"
      I18n.t('faq').each_with_index do |q, index|
         if !q.blank? && !q[:question].blank? && !q[:answer].blank?
          faqs += "<div class='card'>
                    <div class='card-header' id='heading#{index}'>
                      <h5 class='mb-0'>
                        <button class='btn btn-link' data-toggle='collapse' data-target='#collapse#{index}' aria-expanded='false' aria-controls='collapse#{index}'>
                          #{q[:question]}
                        </button>
                      </h5>
                    </div>

                    <div id='collapse#{index}' class='collapse' aria-labelledby='heading#{index}' data-parent='#accordion'>
                      <div class='card-body'>
                        #{q[:answer]}
                      </div>
                    </div>
                  </div>"
         end
      end
      faqs += "</div>"
    end
    faqs.html_safe
  end

  def process_social_media_buttons
    hash = I18n.t('config.contact')
    social_media = ""
    if contact_configured?
      unless hash[:phone].blank?
        phone, error = TwilioHandler.new.get_valid_phone_number(hash[:phone])
        if error.blank?
          url = "tel:#{phone}"
          social_media += "<p>#{process_fa("fa fa-phone-square", nil, phone, url)}</p>"
        end
      end
      unless hash[:email].blank?
        url = "mailto:#{hash[:email]}"
        social_media += "<p>#{process_fa("fa fa-envelope-square", nil, hash[:email], url)}</p>"
      end
      unless hash[:facebook].blank?
        facebook = "http://facebook.com/#{hash[:facebook]}"
        social_media += "<p>#{process_fa("fab fa-facebook-square", nil, hash[:facebook], facebook)}</p>"
      end
      unless hash[:twitter].blank?
        twitter = "http://twitter.com/#{hash[:twitter]}"
        social_media += "<p>#{process_fa("fab fa-twitter-square", nil, hash[:twitter], twitter)}</p>"
      end
      unless hash[:instagram].blank?
        instagram = "http://instagram.com/#{hash[:instagram]}"
        social_media += "<p>#{process_fa("fab fa-instagram-square", nil, hash[:instagram], instagram)}</p>"
      end
    end
    "#{social_media}".html_safe
  end

  ##
  # Returns a parsed payload of a message, separated by the proper separator for the contact method
  # uses_email - whether this result will be sent in email or a text
  def get_contact_message(subject, body, name, method, uses_email)
    separator = (uses_email ? "<br>" : "\n")
    title_text = "#{I18n.t("events.title")}: #{subject}#{separator}"
    if uses_email
      title_text = "<h1>#{title_text}</h1>"
    end
    message_text = "#{I18n.t("events.message")}: #{body}#{separator}"
    name_text = "#{I18n.t("groups.name")}: #{name}#{separator}"
    method_text = "#{I18n.t("static_pages.contact.method")}: #{method}#{separator}"
    "#{title_text}"\
    "#{message_text}"\
    "#{name_text}"\
    "#{method_text}"
  end
end