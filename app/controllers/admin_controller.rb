class AdminController < ApplicationController
  before_action :authenticate_admin!

  def newUser
    render :template => admin_user_new_path
  end

  def createUser
    case params['commit']
    when "Submit CSV"
      redirect_to createUserFromAdminCsv(params)
    else
      redirect_to createUserFromAdminForm(params)
    end
  end

  def newEvent
    render :template => admin_event_new_path
  end

  def editEvent
    if !params['id'].blank? && Event.exists?(id: params['id'])
      render :template => "admin/event/edit", :locals => {event: Event.where(["id = ?", params['id']]).first}
    else
      flash[:notice] = notFoundMessage("event")
      redirect_to root_path
    end
  end

  def modifyEvent
    redirect_to modifyEventFromAdminForm(params)
  end
end