require 'cgi'

class StaticPagesController < ApplicationController
  before_action :authenticate_user!, only: [:form, :results]
  before_action :set_form_vars, only: [:form, :results]
  include StaticPagesHelper

  def home
    if user_signed_in?
      redirect_to events_path
    end
  end

  def faq
    unless faq_configured?
      flash.alert = "#{I18n.t('global.missing_input', types: I18n.t('global.menu.faq'))} #{admin_signed_in?(current_user) ? I18n.t('global.missing_input_admin_prompt_manual') : I18n.t('global.missing_input_user_prompt_manual')}"
      redirect_to root_path
    end
  end

  def contact
    unless contact_configured?
      flash.alert = "#{I18n.t('global.missing_input', types: I18n.t('global.menu.contact'))} #{admin_signed_in?(current_user) ? I18n.t('global.missing_input_admin_prompt_manual') : I18n.t('global.missing_input_user_prompt_manual')}"
      redirect_to root_path
    end
  end

  def contact_send
    if !params[:subject].blank? && !params[:body].blank?
      emails = []
      if current_user && current_user.use_email? && current_user.confirmed?
        emails.push(current_user.email)
      end
      emails.push(I18n.t('config.contact.email'))
      UserMailer.contact_org(params[:subject], params[:body], emails).deliver
      flash.notice = I18n.t("global.model_created", type: I18n.t("global.email").downcase)
    else
      flash.alert = I18n.t("global.error_message", type: I18n.t("global.email").downcase)
    end
    redirect_to contact_path
  end

  def form
    unless form_configured?
      flash.alert = "#{I18n.t('global.missing_input', types: I18n.t('config.form_name'))} #{admin_signed_in?(current_user) ? I18n.t('global.missing_input_admin_prompt_manual') : I18n.t('global.missing_input_user_prompt_manual')}"
      redirect_to root_path
    end
  end

  def results
    if UserScore.find_by(user_id: current_user.id, created_at: (Time.now - 24.hours)..Time.now).present?
      flash.alert = I18n.t('user_score.creation_failed_response')
      redirect_to form_path
    else
      if @answered_questions
        begin
          score, max_score = @form.get_score(@answered_questions)
          subscores = @form.get_subscores
          user_score = UserScore.new(user_id: @user.id)
          if subscores.empty?
            user_score.subscores << Subscore.new(user_score_id: user_score.id,
                                                 name: "score",
                                                 score: score,
                                                 max_score: max_score)
          else
            subscores.each do |key, value|
              user_score.subscores << Subscore.new(user_score_id: user_score.id,
                                                   name: key,
                                                   score: value[0],
                                                   max_score: value[1])
            end
          end
          user_score.save
          @user.user_scores << user_score
          @user.save
          emails = []
          if @user.use_email? && @user.confirmed?
            emails.push(@user.email)
          end
          emails.push(I18n.t("config.smtp.smtp_username"))
          UserMailer.form_create_email(@user, @form, @answered_questions, emails).deliver
          flash.now.notice = I18n.t("global.model_created", type: I18n.t("config.form_name"))
        rescue StandardError => e
          puts(e)
          flash.now.alert = I18n.t("global.error_message", type: I18n.t("config.form_name"))
        end
      end
    end
  end

  private
  def set_form_vars
    @form = FormService.new
    @user = current_user
    @answered_questions = params
  end
end
