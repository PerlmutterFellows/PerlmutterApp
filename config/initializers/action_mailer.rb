Rails.application.configure do
  I18n.load_path += Dir[Rails.root.join('config', 'locales', 'presets', '*.{rb,yml}')]
  I18n.load_path += Dir[Rails.root.join('config', 'locales', 'org', 'config', '*.{rb,yml}')]
  I18n.load_path += Dir[Rails.root.join('config', 'locales', 'org', 'faq', '*.{rb,yml}')]
  I18n.load_path += Dir[Rails.root.join('config', 'locales', 'org', 'form', '*.{rb,yml}')]
  I18n.available_locales = [:en, :es]
  I18n.default_locale = :en

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
      address:              I18n.t('config.smtp.smtp_address'),
      port:                 I18n.t('config.smtp.smtp_port'),
      domain:               'localhost',
      user_name:            I18n.t('config.smtp.smtp_username'),
      password:             I18n.t('config.smtp.smtp_password'),
      authentication:       'plain',
      enable_starttls_auto: true
  }
end