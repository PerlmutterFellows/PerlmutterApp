class AdminController < ApplicationController
  before_action :authenticate_admin!

  def new
  end

  def create
    redirect_to createUserFromAdminForm(params)
  end
end