# frozen_string_literal: true
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_user, only: [:show, :edit, :delete]
  before_action :authenticate_user!, except: [:update]
  before_action :authenticate_moderator!, only: [:index]
  # before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def index
    # Check if any of the search parameters exist, and if they do, filter them. Otherwise, select all users.
    if user_query_present?
      @users = User.filter(session[:name_query], session[:group_query], session[:phone_number_query], session[:email_query], session[:date_query]).user
    else
      @users = User.user
    end
  end

  def moderators
    # Check if any of the search parameters exist, and if they do, filter them. Otherwise, select all users.
    if user_query_present?
      @users = User.filter(session[:name_query], session[:group_query], session[:phone_number_query], session[:email_query], session[:date_query]).moderator
    else
      @users = User.moderator
    end
  end

  def promote_to_moderator
    user_to_promote = User.find(params[:id])
    if current_user.admin? && user_to_promote.user?
      user_to_promote.moderator!
      user_to_promote.save
    end
    redirect_to users_path
  end

  def demote_to_user
    user_to_demote = User.find(params[:id])
    if current_user.admin? && user_to_demote.moderator?
      user_to_demote.user!
      user_to_demote.save
    end
    redirect_to moderators_path
  end

  def clear_user_search
    reset_filters
    if URI(request.referer).path.include?("users")
      redirect_to moderators_path
    else
      redirect_to users_path
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

  def update_user
    user = User.find(params[:id])
    initial_email = user[:email]
    initial_phone_number = user[:phone_number]
    initial_use_call = user[:use_call]
    initial_use_text = user[:use_text]
    path = user_path(user)
    if user.update_attributes(user_params)
      if user_params[:email] != initial_email
        sign_out user
        path = root_path
      end
      if user_params[:phone_number] != initial_phone_number
        user.call_confirmation_sent_at = nil
        user.call_confirmed_at = nil
        user.text_confirmation_sent_at = nil
        user.text_confirmed_at = nil
      end
      if !user_params[:use_call].to_i.zero? != initial_use_call
        user.call_confirmation_sent_at = nil
        user.call_confirmed_at = nil
      end
      if !user_params[:use_text].to_i.zero? != initial_use_text
        user.text_confirmation_sent_at = nil
        user.text_confirmed_at = nil
      end
      user.save
      flash.notice = t('devise.registrations.updated')
    else
      flash.alert = user.errors.full_messages.join('<br>')
    end
    redirect_to path
  end

  def get_user_score_data
    user = User.find(params[:id])
    render json: map_user_scores(user)
  end

  def get_user_subscore_data
    user = User.find(params[:id])
    render json:  map_user_subscores(user)
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

   #PUT /resource
   #def update
   #  super
   #end

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

   #If you have extra params to permit, append them to the sanitizer.
   def configure_account_update_params
     devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :email, :phone_number, :locale, :role, :use_email, :use_call, :use_text])
   end

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

  def user_params
    params.require(:user).permit(:first_name, :last_name, :birthday, :phone_number, :email, :use_email, :use_call, :use_text)
  end

  def user_query_present?
    queries = [:name_query, :email_query, :phone_number_query, :group_query, :date_query]
    queries.each do |query|
      if session[query].present?
        return true
      end
    end
    return false
  end

  def set_user
    @user = User.find(params[:id])
  end
end
