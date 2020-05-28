class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token

  def recCall
    # TODO implement call_handler
  end

  def recText
    puts(params)
    user = User.where(["phone_number = ?", params[:From].to_s]).first
    puts(user.confirmed_at)
    response = TextHandler.new.processInput(user, params)
    puts(User.where(["phone_number = ?", params[:From].to_s]).first.confirmed_at)
    render xml: TwilioHandler.new.send_respond_text(response).to_s
  end
end
