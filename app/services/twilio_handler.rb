
class TwilioHandler
  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new
  end

  def set_dev_callbacks(url)
    client.incoming_phone_numbers(ENV['sid']).update(
      sms_url: "#{url}/receive_text",
      voice_url: "#{url}/receive_call"
    )

    incoming_phone_number = client.incoming_phone_numbers(ENV['sid']).fetch
    [incoming_phone_number.sms_url, incoming_phone_number.voice_url]
  end

  def get_valid_phone_number(inputted_number)
    valid_number = nil
    error = nil
    begin
      valid_number = client.lookups
          .phone_numbers(inputted_number)
          .fetch.phone_number
    rescue Twilio::REST::RestError => e
      error = e
    end
    [valid_number, error]
  end

  def send_text(user, message)
    success = true
    error = nil
    begin
    client.api.account.messages.create(
        to: user.phone_number,
        from: ENV['phone_number'],
        body: message
    )
    user.text_confirmation_sent_at = DateTime.now
    rescue StandardError => e
      success = false
      error = e.message.squish
    end
    [success, error]
  end

  def send_respond_text(message)
    text_response = nil
    begin
      text_response = Twilio::TwiML::MessagingResponse.new do |r|
        r.message body: message
      end
    rescue StandardError => e
      puts("Twilio Send Response Error: #{e.message.squish}")
    end
    text_response
  end

  def send_call(user, message)
    success = true
    error = nil
    begin
    client.calls.create(
          to: user.phone_number,
          from: ENV['phone_number'],
          twiml: "<Response>
                    <Say>#{message}</Say>
                    <Gather finishOnKey='#' timeout='15' action='#{Rails.application.routes.url_helpers.url_for(action: 'receive_call', controller: 'twilio', only_path: false)}' method='POST'></Gather>
                    <Say>#{I18n.t('texts.dialer_failed')}</Say>
                  </Response>"
      )
    user.call_confirmation_sent_at = DateTime.now
    rescue StandardError => e
      success = false
      error = e.message.squish
    end
    [success, error]
  end

  def send_respond_call(user, message)
    voice_response = nil
    begin
      voice_response = Twilio::TwiML::VoiceResponse.new do |r|
        r.say(message: message)
        r.gather(action: Rails.application.routes.url_helpers.url_for(action: 'receive_call', controller: 'twilio', only_path: false), method: 'POST') do |gather|
          gather.say(message: I18n.t('texts.confirmation',
                                name: user.first_name,
                                organization_name: I18n.t('global.organization_name'),
                                prompt: I18n.t('texts.dialer_prompt',
                                          yes: I18n.t('texts.call_yes'),
                                          no: I18n.t('texts.call_no'))))
        end
        r.say(message: I18n.t('texts.dialer_failed'))
      end
    rescue StandardError => e
      puts("Twilio Send Response Error: #{e.message.squish}")
    end
    voice_response
  end
end