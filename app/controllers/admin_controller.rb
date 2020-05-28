class AdminController < ApplicationController
  before_action :authenticate_admin!

  def new
  end

  def create
    case params['commit']
    when "Submit CSV"
      redirect_to createUserFromAdminCsv(params)
    else
      redirect_to createUserFromAdminForm(params)
    end
  end
end