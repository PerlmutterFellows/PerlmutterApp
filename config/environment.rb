# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.configure do

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                 587,
      domain:               'gmail.com',
      user_name:            ENV['GMAIL_USERNAME'],
      password:             ENV['GMAIL_PASSWORD'],
      authentication:       'plain',
      enable_starttls_auto: true
  }
end

Rails.application.initialize!
