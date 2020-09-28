class UserMailer < Devise::Mailer
  helper :application
  helper :events
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  def base_mail(user, event, subject)
    @user = user
    @event = event
    I18n.with_locale(user.get_locale) do
      mail(from: I18n.t('config.smtp.smtp_username'), to: user.email, subject: subject)
    end
  end

  def form_create_email(user, form, answered_questions, emails)
    @user = user
    @form = form
    @answered_questions = answered_questions
    I18n.with_locale(user.get_locale) do
      mail(from: I18n.t('config.smtp.smtp_username'), to: emails, subject: "#{I18n.t("global.new")} #{I18n.t("config.form_name")}")
    end
  end

  def contact_org(subject, body, name, method, emails)
    @subject = subject
    @body = body
    @name = name
    @method = method
    I18n.with_locale(I18n.locale) do
      mail(from: I18n.t('config.smtp.smtp_username'), to: emails, subject: @subject)
    end
  end

  def event_create_email(user, event)
    base_mail(user, event, "#{I18n.t("global.new")} #{event.eventType}: #{event.title}")
  end

  def event_update_email(user, event)
    base_mail(user, event, "#{I18n.t("global.updated")} #{event.eventType}: #{event.title}")
  end

  def event_delete_email(user, event)
    base_mail(user, event, "#{I18n.t("global.deleted")} #{event.eventType}: #{event.title}")
  end
end