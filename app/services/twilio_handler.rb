class TwilioHandler
  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new
  end

  def send_text(user, message)
    client.api.account.messages.create(
        to: user.phone_number,
        from: ENV['phone_number'],
        body: message
    )
  end

  def send_respond_text(message)
    Twilio::TwiML::MessagingResponse.new do |r|
      r.message body: message
    end
  end

  def send_call(user, message)
    client.calls.create(
        to: user.phone_number,
        from: ENV['phone_number'],
        twiml: "<Response><Say>#{message}</Say></Response>"
    )
  end

  def send_respond_call(message)
    Twilio::TwiML::VoiceResponse.new do |r|
      response.say(message: message)
    end
  end
end