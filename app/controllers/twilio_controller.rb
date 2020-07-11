class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive_call
    phone = params[:Called].to_s
    user = User.where(["phone_number = ?", phone]).first
    I18n.with_locale(user.get_locale) do
      response = ""
      unless params[:Digits].blank?
        response = TextHandler.new.process_input(user, params[:Digits], false)
      end
      render xml: TwilioHandler.new.send_respond_call(user, response).to_s
    end
  end

  def receive_text
    phone = params[:From].to_s
    user = User.where(["phone_number = ?", phone]).first
    I18n.with_locale(user.get_locale) do
      response = ""
      unless params[:Body].blank?
        response = TextHandler.new.process_input(user, params[:Body].upcase, true)
      end
      render xml: TwilioHandler.new.send_respond_text(response).to_s
    end
  end
end
