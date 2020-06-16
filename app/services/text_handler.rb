class TextHandler

  def process_input(user, params)
    body = params[:Body].upcase

    case body
    when "CONFIRM"
      if user.confirmed_at.blank?
        user.confirmed_at = DateTime.now
        user.confirmation_sent_at = DateTime.now
        user.save
        I18n.t('texts.confirmation_success_response')
      else
        I18n.t('texts.confirmation_failed_response')
      end
    when "STOP"
      if user.confirmed_at.blank?
        I18n.t('texts.stop_failed_response')
      else
        user.confirmed_at = nil
        user.confirmation_sent_at = nil
        user.save
        I18n.t('texts.stop_success_response')
      end
    else
      I18n.t('global.invalid_input')
    end
  end
end