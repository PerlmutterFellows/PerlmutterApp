class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token

  def recCall
    # TODO implement call_handler
  end

  def recText
    user = User.where(["phone_number = ?", params[:From].to_s]).first
    response = TextHandler.new.processInput(user, params)
    render xml: TwilioHandler.new.send_respond_text(response).to_s
  end
end
