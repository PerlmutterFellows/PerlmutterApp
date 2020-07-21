class UserMailer < Devise::Mailer
  helper :application
  helper :events
  include Devise::Controllers::UrlHelpers
  default from: ENV['GMAIL_USERNAME']
  default template_path: 'devise/mailer'

  def base_mail(user, event, subject)
    @user = user
    @event = event
    mail(to: user.email, subject: subject)
  end

  def form_create_email(user, form, answered_questions, emails)
    @user = user
    @form = form
    @answered_questions = answered_questions
    mail(to: emails, subject: "#{I18n.t("global.new")} #{I18n.t("global.menu.form")}")
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