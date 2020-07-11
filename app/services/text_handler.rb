class TextHandler

  def process_input(user, input, is_text)
    yes = is_text ? I18n.t('texts.text_yes') : I18n.t('texts.call_yes')
    no = is_text ? I18n.t('texts.text_no') : I18n.t('texts.call_no')
    is_confirmed = is_text ? user.confirmed_text? : user.confirmed_call?
    case input
    when yes
      if !is_confirmed
        is_text ? user.text_confirmed_at = DateTime.now : user.call_confirmed_at = DateTime.now
        user.save
        I18n.t('texts.confirmation_success_response')
      else
        I18n.t('texts.confirmation_failed_response')
      end
    when no
      if !is_confirmed
        I18n.t('texts.stop_failed_response')
      else
        is_text ? user.text_confirmed_at = nil : user.call_confirmed_at = nil
        user.save
        I18n.t('texts.stop_success_response')
      end
    else
      process_rsvp(user, input, yes, no)
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
          output = ApplicationController.new.toggle_attendance(user.id, event.id, true, false)
        when no
          output = ApplicationController.new.toggle_attendance(user.id, event.id, false, false)
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
    if I18n.t('faq').kind_of?(Array) && I18n.t('faq').count != 0
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
    hash = I18n.t('contact')
    social_media = ""
    if I18n.t('contact').kind_of?(Hash)
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

end