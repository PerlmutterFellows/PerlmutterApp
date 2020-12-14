require 'csv'
require 'date'
require 'time'
require 'cgi'

module RegistrationsHelper

  def generate_password_by_name(user)
    if !user.first_name.blank? && !user.last_name.blank?
      user.password = user.first_name.to_s[0] + user.last_name.to_s.downcase
      while user.password.length < 6
        user.password += (('a'..'z').to_a.concat (('1'...'10').to_a)).sample
      end
      user.password = user.password.gsub(' ', '_')
      user.password_confirmation = user.password
    end
  end

  def send_confirmation_phone(user, is_text)
    confirmed = is_text ? user.confirmed_text? : user.confirmed_call?
    message_text = I18n.t('texts.confirmation',
                     name: user.first_name,
                     organization_name: I18n.t('config.organization_name'),
                     prompt: I18n.t('texts.user_confirmation_prompt',
                               yes: I18n.t('texts.text_yes'),
                               no: I18n.t('texts.text_no')))
    message_call = I18n.t('texts.confirmation',
                     name: user.first_name,
                     organization_name: I18n.t('config.organization_name'),
                     prompt: I18n.t('texts.dialer_prompt',
                               yes: I18n.t('texts.call_yes'),
                               no: I18n.t('texts.call_no'),
                               pound: I18n.t('texts.pound')))
    unless confirmed
      success, error = is_text ? TwilioHandler.new.send_text(user, message_text) : TwilioHandler.new.send_call(user, message_call)
      if success
        is_text ? user.text_confirmation_sent_at = DateTime.now : user.call_confirmation_sent_at = DateTime.now
        user.save
      end
    end
  end

  def handle_user_creation(created_user)
    if created_user.save
      flash.notice = t('devise.registrations.signed_up_but_unconfirmed')
      root_path
    else
      created_user.delete
      flash.alert = t('global.error_message', type: "user")
      users_new_path
    end
  end

  def create_user_from_admin_csv(params)

    failed_rows = []
    success_rows = []
    index = 2

    CSV.foreach(params['file'].path, 'r:bom|utf-8', headers: true) do |row|
      user = User.new

      user.first_name = row["first_name"]
      user.last_name = row["last_name"]
      user.email = row["email"]
      user.phone_number = row["phone_number"]
      user.password = row["password"]
      user.role = row["role"]
      user.use_call = row["use_call"]
      user.use_text = row["use_text"]
      user.use_email = row["use_email"]
      user.birthday = row["birthday"]

      if user.password.blank?
        generate_password_by_name(user)
      end

      if user.valid?
        if handle_user_creation(user)
          success_rows.push(index)
        else
          failed_rows.push("#{index}: #{CGI.escapeHTML(user.errors.full_messages.to_sentence)}")
        end
      else
        failed_rows.push("#{index}: #{CGI.escapeHTML(user.errors.full_messages.to_sentence)}")
      end

      index += 1
    end

    if failed_rows.length == 0
      flash.notice = t('.csv_success')
    elsif success_rows.length == 0
      flash.alert = t('.csv_failures', rows: failed_rows.join('<br>'))
    else
      flash.alert = t('.csv_success_with_failures', rows: failed_rows.join('<br>'))
    end
    root_path
  end
end
