class TwilioHandler
  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new
  end

  def send_text(user, message)
    begin
    client.api.account.messages.create(
        to: user.phone_number,
        from: ENV['phone_number'],
        body: message
    )
    rescue Twilio::REST::RequestError => e
      flash[:error] = t('texts.error', error: e)
      false
    else
      true
    end
  end

  def send_respond_text(message)
    text_response = nil
    begin
      text_response = Twilio::TwiML::MessagingResponse.new do |r|
        r.message body: message
      end
    rescue Twilio::TwiMLError => e
      flash[:error] = t('texts.error', error: e)
    end
    text_response
  end

  def send_call(user, message)
    begin
      client.calls.create(
          to: user.phone_number,
          from: ENV['phone_number'],
          twiml: "<Response><Say>#{message}</Say></Response>"
      )
    rescue Twilio::REST::RequestError => e
      flash[:error] = t('texts.error', error: e)
      false
    else
      true
    end
  end

  def send_respond_call(message)
    voice_response = nil
    begin
      voice_response = Twilio::TwiML::VoiceResponse.new do |r|
        response.say(message: message)
      end
    rescue Twilio::TwiMLError => e
      flash[:error] = t('texts.error', error: e)
    end
    voice_response
  end
end