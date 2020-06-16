class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive_call
    # TODO implement call_handler
  end

  def receive_text
    phone = params[:From].to_s
    user = User.where(["phone_number = ?", phone]).first
    response = TextHandler.new.process_input(user, params)
    render xml: TwilioHandler.new.send_respond_text(response).to_s
  end
end
