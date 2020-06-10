class TextHandler

  def process_input(user, params)
    body = params[:Body].upcase

    case body
    when "CONFIRM"
      if user.confirmed_at.blank?
        user.confirmed_at = DateTime.now
        user.confirmation_sent_at = DateTime.now
        user.save
        t('texts.confirmation_success_response')
      else
        t('texts.confirmation_failed_response')
      end
    when "STOP"
      if user.confirmed_at.blank?
        t('texts.stop_failed_response')
      else
        user.confirmed_at = nil
        user.confirmation_sent_at = nil
        user.save
        t('texts.stop_success_response')
      end
    else
      t('global.invalid_input')
    end
  end
end