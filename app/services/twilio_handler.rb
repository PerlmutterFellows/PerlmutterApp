
class TwilioHandler
  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new
  end

  # As per Twilio, to have multilingual/special
  # characters, a UCS2 punctuation space must
  # be added to the end of the text input.
  def force_twilio_ucs2_encoding(message)
    punctuation_space = "\u{2008}"
    "#{message}#{punctuation_space}"
  end

  def set_dev_callbacks(url)
    sms_url = ""
    voice_url = ""
    begin
      client.incoming_phone_numbers(I18n.t('config.phone.phone_sid')).update(
        sms_url: "#{url}/receive_text",
        voice_url: "#{url}/receive_call"
      )

      incoming_phone_number = client.incoming_phone_numbers(I18n.t('config.phone.phone_sid')).fetch
      sms_url = incoming_phone_number.sms_url
      voice_url = incoming_phone_number.voice_url
    rescue StandardError => e
      error = e.message.squish
      puts("Twilio Send Response Error: #{error}")
    end
    [sms_url, voice_url]
  end

  def get_valid_phone_number(inputted_number)
    valid_number = nil
    error = nil
    begin
      valid_number = client.lookups
          .phone_numbers(inputted_number)
          .fetch.phone_number
    rescue StandardError => e
      error = e.message.squish
      puts("Twilio Send Response Error: #{error}")
    end
    [valid_number, error]
  end

  def send_text(user, message)
    success = true
    error = nil
    begin
    client.api.account.messages.create(
        to: user.phone_number,
        from: I18n.t('config.phone.phone_number'),
        body: force_twilio_ucs2_encoding(message)
    )
    user.text_confirmation_sent_at = DateTime.now
    rescue StandardError => e
      success = false
      error = e.message.squish
      puts("Twilio Send Response Error: #{error}")
    end
    [success, error]
  end

  def send_respond_text(message)
    text_response = nil
    begin
      text_response = Twilio::TwiML::MessagingResponse.new do |r|
        r.message body: force_twilio_ucs2_encoding(message)
      end
    rescue StandardError => e
      puts("Twilio Send Response Error: #{e.message.squish}")
    end
    text_response
  end

  def send_call(user, message)
    success = true
    error = nil
    callback = Rails.application.routes.url_helpers.url_for(action: 'receive_call', controller: 'twilio', only_path: false)
    if !user.blank?
      voice = user.get_locale == :en ? 'Polly.Matthew-Neural' : 'Polly.Lupe-Neural'
    else
      voice = 'Polly.Matthew-Neural'
    end
    begin
    message_twiml = message.lines.map { |line| "<Say voice='#{voice}'>#{line}</Say>" }.join()
    client.calls.create(
          to: user.phone_number,
          from: I18n.t('config.phone.phone_number'),
          twiml: "<Response>
                      <Gather finishOnKey='#' timeout='30' action='#{callback}' method='POST'>
                        #{message_twiml}
                      </Gather>
                    <Say voice='#{voice}'>#{I18n.t('texts.dialer_failed')}</Say>
                  </Response>"
      )
    user.call_confirmation_sent_at = DateTime.now
    rescue StandardError => e
      success = false
      error = e.message.squish
      puts("Twilio Send Response Error: #{error}")
    end
    [success, error]
  end

  def send_respond_call(user, message)
    voice_response = nil
    callback = Rails.application.routes.url_helpers.url_for(action: 'receive_call', controller: 'twilio', only_path: false)
    if !user.blank?
      voice = user.get_locale == :en ? 'Polly.Matthew-Neural' : 'Polly.Lupe-Neural'
      name = user.first_name
    else
      voice = 'Polly.Matthew-Neural'
      name = ""
    end
    begin
      voice_response = Twilio::TwiML::VoiceResponse.new do |r|
        r.gather(finish_on_key: '#', timeout: 30, action: callback, method: 'POST') do |gather|
          message.lines.each do |line|
            gather.say(voice: voice, message: line)
          end
          gather.say(voice: voice, message: I18n.t('texts.confirmation',
                                name: name,
                                organization_name: I18n.t('config.organization_name'),
                                prompt: I18n.t('texts.dialer_prompt',
                                          yes: I18n.t('texts.call_yes'),
                                          no: I18n.t('texts.call_no'),
                                          pound: I18n.t('texts.pound'))))
        end
        r.say(voice: voice, message: I18n.t('texts.dialer_failed'))
      end
    rescue StandardError => e
      puts("Twilio Send Response Error: #{e.message.squish}")
    end
    voice_response
  end
end