class TextHandler
  def getTextConfirmation(user)
    "Welcome #{user.first_name} to #{ENV["org"]}! Respond CONFIRM to confirm your interest in notifications, STOP to cancel."
  end

  def processInput(user, params)
    body = params[:Body].upcase

    case body
    when "CONFIRM"
      if user.confirmed_at.blank?
        user.confirmed_at = DateTime.now
        user.confirmation_sent_at = DateTime.now
        user.save
        "Thanks! You are now confirmed!"
      else
        "You are already confirmed!"
      end
    when "STOP"
      if user.confirmed_at.blank?
        "You already do not receive notifications. Please reregister to recieve notifications."
      else
        user.confirmed_at = nil
        user.confirmation_sent_at = nil
        user.save
        "You will no longer receive notifications."
      end
    else
      "Invalid input. Please try again."
    end
  end
end