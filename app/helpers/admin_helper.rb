require 'csv'
require 'date'
require 'time'


module AdminHelper

  def typeMissingMessage
    "Creation failed. Please input either email, phone number, or both."
  end

  def eventSuccessMessage
    "Your event was successful!"
  end

  def notFoundMessage(type)
    "Your #{type} was not found. Please try again, and if this persists, contact the administrator."
  end

  def errorMessage(type)
    "An error has occurred saving your #{type}. Please contact the administrator."
  end

  def accountTakenMessage(type)
    "Your #{type} is taken. Please enter a unique #{type}."
  end

  def confirmationMessage(type)
    "A confirmation message has been sent to the user's #{type}. Please follow the instructions sent to the user's #{type} to activate the account."
  end

  def csvNumSuccessesMessage(list)
    "Users have been created. The following rows failed: #{list.join(',')}"
  end

  def createUserFromAdminForm(params)
    path = admin_user_new_path
    email = params['email'].delete(' ')
    phone = params['phone_number'].delete(' ')
    parsedPhone = "+1#{phone.gsub(/\D/, "")}"
    pass = params['first_name'][0] + params['last_name'].downcase

    @user = User.new(:first_name => params['first_name'],
                     :last_name => params['last_name'],
                     :password => pass,
                     :password_confirmation => pass)

    case
    when email.blank? && phone.blank?
      flash[:notice] = typeMissingMessage
    when email.blank?
      @user.phone_number = parsedPhone
      if @user.save
        TwilioHandler.new.send_text(@user, TextHandler.new.getTextConfirmation(@user))
        flash[:notice] = confirmationMessage("phone number")
        path = root_path
      elsif User.exists?(phone_number: parsedPhone)
        flash[:notice] = accountTakenMessage("phone number")
      else
        flash[:notice] = errorMessage("user")
      end
    else
      @user.email = email
      @user.phone_number = parsedPhone
      if @user.save
        flash[:notice] = confirmationMessage("email address")
        path = root_path
      elsif User.exists?(email: email)
        flash[:notice] = accountTakenMessage("email address")
      else
        flash[:notice] = errorMessage("user")
      end
    end
    path
  end

  def createUserFromAdminCsv(params)
    if current_user.csv_file.attached?
      current_user.csv_file.purge
    end

    current_user.csv_file.attach(params['file'])

    if current_user.save
      failed_rows = []
      index = 2
      CSV.parse(current_user.csv_file.download, headers: true) do |row|
        pass = nil
        email = row['email']&.to_s&.delete(' ')
        phone = row['phone_number']&.to_s&.delete(' ')&.gsub(/\D/, "")

        if !row['first_name'].blank? && !row['last_name'].blank?
          pass = row['first_name'].to_s[0] + row['last_name'].to_s.downcase
        end

        user = User.new(:first_name => row['first_name'].to_s,
                        :last_name => row['last_name'].to_s,
                        :password => pass,
                        :password_confirmation => pass)

        case
        when email.blank? && phone.blank?
          failed_rows.push(index)
        when email.blank? && phone.match('\d{10}')
          user.phone_number = "+1#{phone}"
          if user.save
            TwilioHandler.new.send_text(user, TextHandler.new.getTextConfirmation(user))
          else
            failed_rows.push(index)
          end
        else
          user.email = email
          user.phone_number = "+1#{phone}"
          unless user.save
            failed_rows.push(index)
          end
        end
        index += 1
      end
      current_user.csv_file.purge
      flash[:notice] = csvNumSuccessesMessage(failed_rows)
      root_path
    else
      flash[:notice] = errorMessage("user")
      admin_user_new_path
    end
  end

  def modifyEventFromAdminForm(params)
    path = admin_event_new_path

    if Event.exists?(id: params['id'])
      @event = Event.where(["id = ?", params['id']]).first
    else
      @event = Event.new
    end

    @event.title = params['title']
    @event.description = params['description']
    @event.tag = params['tag']
    @event.to = params['to']
    @event.published = params['published']

    unless params['date'].blank?
      @event.date = params['date']
    end

    unless params['time'].blank?
      @event.time = params['time']
    end

    if @event.save
      # invoke publish if published
      flash[:notice] = eventSuccessMessage
      path = root_path
    else
      flash[:notice] = errorMessage("event")
    end
  path
  end
end
