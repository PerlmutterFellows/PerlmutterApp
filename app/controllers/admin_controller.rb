class AdminController < ApplicationController
  before_action :authenticate_admin!

  def new
  end

  def create
    path = root_path
    pass = params['first_name'][0] + params['last_name'].downcase
    phone = "+1#{params['phone_number'].gsub(/\D/, "")}"

    if params['email'].delete(' ').blank? && params['phone_number'].delete(' ').blank?
      notice = "Creation failed. Please input either email, phone number, or both."
      path = admin_user_new_path
    elsif params['email'].delete(' ').blank? && params['phone_number'].to_i.to_s != params['phone_number']
      notice = "Creation failed. Please input a valid phone number in 1234567890 format, no dashes, characters, parentheses or spaces."
      path = admin_user_new_path
    elsif params['email'].delete(' ').blank?
      @user = User.new(:first_name => params['first_name'], :last_name => params['last_name'], :phone_number => phone, :password => pass, :password_confirmation => pass)
      if @user.save
        TwilioHandler.new.send_text(@user, TextHandler.new.getTextConfirmation(@user))
        notice = "A message with a confirmation code has been sent to the user's phone. Please respond to activate the account."
      elsif User.exists?(phone_number: phone)
        notice = "Your phone number is taken. Please enter a unique phone number."
        path = admin_user_new_path
      else
        notice = "An error has occurred saving your user. Please contact the administrator."
        path = admin_user_new_path
      end
    else
      @user = User.new(:first_name => params['first_name'], :last_name => params['last_name'], :email => params['email'], :password => pass, :password_confirmation => pass)
      if @user.save
        notice = "A message with a confirmation link has been sent to the user's email address. Please follow the link to activate the account."
      elsif User.exists?(email: params['email'])
        notice = "Your email address is taken. Please enter a unique email address."
        path = admin_user_new_path
      else
        notice = "An error has occurred saving your user. Please contact the administrator."
        path = admin_user_new_path
      end
    end
    flash[:notice] = notice
    redirect_to path
  end
end