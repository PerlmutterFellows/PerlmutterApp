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
      user.password_confirmation = user.password
    end
  end

  def send_confirmation_text(user)
    if !user.phone_number.blank? && user.email.blank? && !user.confirmed_at.blank?
      success, error = TwilioHandler.new.send_text(user, t('texts.confirmation', name: user.first_name, organization_name: t('global.organization_name')))
      unless success
        user.delete
        flash[:error] = t('global.error_message', type: "user")
      end
    end
  end

  def handle_user_creation(created_user)
    if created_user.save
      flash[:success] = t('devise.registrations.signed_up_but_unconfirmed')
      root_path
    else
      created_user.delete
      flash[:error] = t('global.error_message', type: "user")
      admin_user_new_path
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
      flash[:success] = t('.csv_success')
    elsif success_rows.length == 0
      flash[:error] = t('.csv_failures', rows: failed_rows.join('<br>'))
    else
      flash[:warning] = t('.csv_success_with_failures', rows: failed_rows.join('<br>'))
    end
    root_path
  end
end
