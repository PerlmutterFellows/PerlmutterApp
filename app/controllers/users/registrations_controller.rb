# frozen_string_literal: true
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_user, only: [:show, :edit, :delete]
  before_action :redirect_if_not_admin, only: [:index]
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  def index
    # Check if any of the search parameters exist, and if they do, filter them. Otherwise, select all users.
    if user_query_present?
      @users = User.filter(session[:name_query], session[:group_query], session[:phone_number_query], session[:email_query])
    else
      @users = User.all
    end
  end

  def show
    if (user_signed_in? && @user.id == current_user.id) || admin_signed_in?(current_user)
      render :template => 'devise/registrations/show'
    else
      authenticate_admin!
    end
  end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #    super
  # end

  def new_by_admin
    unless authenticate_admin!
      render :template => 'devise/registrations/new_by_admin', :locals => {user: User.new}
    end
  end

  def create_by_admin
    unless authenticate_admin!
      case params['commit']
      when "Submit CSV"
        redirect_to create_user_from_admin_csv(params)
      else
        created_user = User.new(sign_up_params)
        generate_password_by_name(created_user)

        if created_user.valid?
          redirect_to handle_user_creation(created_user)
        else
          render :template => 'devise/registrations/new_by_admin', :locals => {user: created_user}
        end
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  def delete
    if current_user.id.to_i == @user.id.to_i
      destroy_user(current_user, root_path)
    else
      authenticate_admin!
      destroy_user(@user, users_path)
    end
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :phone_number, :locale, :role, :use_email, :use_call, :use_text])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  #
  private

  def user_query_present?
    queries = [:name_query, :email_query, :phone_number_query, :group_query]
    queries.each do |query|
      if session[query].present?
        return true
      end
    end
    return false
  end

  def redirect_if_not_admin
    redirect_to events_path if !current_user.admin?
  end

  def set_user
    @user = User.find(params[:id])
  end
end
