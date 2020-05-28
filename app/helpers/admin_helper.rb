module AdminHelper

  def typeMissingMessage
    "Creation failed. Please input either email, phone number, or both."
  end

  def errorMessage
    "An error has occurred saving your user. Please contact the administrator."
  end

  def accountTakenMessage(type)
    "Your #{type} is taken. Please enter a unique #{type}."
  end

  def confirmationMessage(type)
    "A confirmation message has been sent to the user's #{type}. Please follow the instructions sent to the user's #{type} to activate the account."
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
        flash[:notice] = errorMessage
      end
    else
      @user.email = email
      if @user.save
        flash[:notice] = confirmationMessage("email address")
        path = root_path
      elsif User.exists?(email: email)
        flash[:notice] = accountTakenMessage("email address")
      else
        flash[:notice] = errorMessage
      end
    end
    path
  end
end
