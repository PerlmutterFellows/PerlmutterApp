class UserMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  helper :events
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default from: "perlmutterteam@gmail.com"
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  def base_mail(user, event, subject)
    @user = user
    @event = event
    mail(to: user.email, subject: subject)
  end

  def event_create_email(user, event)
    base_mail(user, event, "New #{event.eventType}: #{event.title}")
  end

  def event_update_email(user, event)
    base_mail(user, event, "Updated #{event.eventType}: #{event.title}")
  end

  def event_delete_email(user, event)
    base_mail(user, event, "Deleted #{event.eventType}: #{event.title}")
  end
end