class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive_text
    recieve_phone(true, params)
  end

  def receive_call
    recieve_phone(false, params)
  end

  private

  def recieve_phone(is_text, params)
    if is_text
      phone = params[:From].to_s
      input = params[:Body]
    else
      phone = ENV['phone_number'] == params[:Caller].to_s ? params[:Called].to_s : params[:Caller].to_s
      input = params[:Digits]
    end

    print(phone)
    user = User.find_by(phone_number: phone)
    locale = user.blank? ? I18n.locale : user.get_locale

    I18n.with_locale(locale) do
      response = ""
      unless input.blank?
        response = TextHandler.new.process_input(user, input.to_s.upcase, is_text)
      end

      if is_text
        render xml: TwilioHandler.new.send_respond_text(response).to_s
      else
        render xml: TwilioHandler.new.send_respond_call(user, response).to_s
      end
    end
  end

end
