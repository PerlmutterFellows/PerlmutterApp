require 'csv'
require 'date'
require 'time'


module RegistrationsHelper
  def create_user_from_admin_form(created_user)
    path = admin_user_new_path
    created_user.password = created_user.first_name[0] + created_user.last_name.downcase
    created_user.password_confirmation = created_user.password
    case
    when created_user.email.blank?
      if created_user.save
        flash[:success] = t('devise.registrations.signed_up_but_unconfirmed')
        TwilioHandler.new.send_text(created_user, t('texts.confirmation', name: created_user.first_name, organization_name: ENV["org"]))
        path = root_path
      else
        flash[:error] = t('global.error_message', type: "user")
      end
    else
      if created_user.save
        path = root_path
        flash[:success] = t('devise.registrations.signed_up_but_unconfirmed')
      else
        flash[:error] = t('global.error_message', type: "user")
      end
    end
    path
  end

  def create_user_from_admin_csv(params)
    if current_user.csv_file.attached?
      current_user.csv_file.purge
    end

    current_user.csv_file.attach(params['file'])

    if current_user.save
      failed_rows = []
      success_rows = []
      index = 2

      CSV.parse(current_user.csv_file.download.force_encoding('utf-8'), headers: true) do |row|
        user = User.new
        transformed_row = row.to_hash.transform_keys{ |key| key }
        puts(transformed_row)

        user.first_name = transformed_row["first_name"]
        user.last_name = transformed_row["last_name"]
        user.email = transformed_row["email"]
        user.phone_number = transformed_row["phone_number"]
        user.password = transformed_row["password"]

        unless user.password.blank?
          if !user.first_name.blank? && !user.last_name.blank?
            user.password = user.first_name.to_s[0] + user.last_name.to_s.downcase
            user.password_confirmation = user.password
          end
        end

        if user.valid?
          case
          when user.email.blank?
            if user.save
              if TwilioHandler.new.send_text(user, t('texts.confirmation', name: user.first_name))
                success_rows.push(index)
              else
                failed_rows.push("#{index}: #{flash[:error]}")
              end
            else
              failed_rows.push("#{index}: #{user.errors.full_messages.to_sentence}")
            end
          else
            if user.save
              success_rows.push(index)
            else
              failed_rows.push("#{index}: #{user.errors.full_messages.to_sentence}")
            end
          end
        else
          user.errors.full_messages.each do |message|
            puts(message)
          end
          failed_rows.push("#{index}: #{user.errors.full_messages.to_sentence}")
        end
        index += 1
      end

      puts(failed_rows.length)
      puts(success_rows.length)
      current_user.csv_file.purge
      if failed_rows.length == 0
        flash[:success] = t('devise.registrations.new_by_admin.csv_success')
      elsif success_rows.length == 0
        flash[:error] = t('devise.registrations.new_by_admin.csv_failures')
      else
        flash[:success] = t('devise.registrations.new_by_admin.csv_success_with_failures', rows: failed_rows.join('\n'))
      end
      root_path
    else
      flash[:error] = t('global.error_message', type: "users")
      admin_user_new_path
    end
  end
end
