Twilio.configure do |config|
  config.account_sid = I18n.t('config.phone.account_sid')
  config.auth_token  = I18n.t('config.phone.auth_token')
end