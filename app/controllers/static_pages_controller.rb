require 'cgi'

class StaticPagesController < ApplicationController
  before_action :authenticate_user!, only: [:form, :results]
  before_action :set_form_vars, only: [:form, :results]

  def home
    if user_signed_in?
      redirect_to events_path
    end
  end

  def faq
  end

  def contact
  end

  def contact_send
    if !params[:subject].blank?
      subject = params[:subject]
    else
      subject = ""
    end

    if !params[:body].blank?
      body = params[:body]
    else
      body = ""
    end

    if !params[:text].blank?
      body = CGI.escape("#{I18n.t("global.subject")}: #{subject}\n#{I18n.t("global.message")}: #{body}")
      url = "sms:#{I18n.t('contact')[:phone]}?&body=#{body}"
    else
      url = "mailto:#{I18n.t('contact')[:email]}?subject=#{subject}&body=#{body}"
    end
    respond_to do |format|
      format.js { render js: "window.top.open('#{url}', '_blank');" }
    end
  end

  def form
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
          emails.push(ENV['GMAIL_USERNAME'])
          UserMailer.form_create_email(@user, @form, @answered_questions, emails).deliver
          flash.now.notice = I18n.t("global.model_created", type: I18n.t("global.menu.form"))
        rescue StandardError => e
          flash.now.alert = I18n.t("global.error_message", type: I18n.t("global.menu.form"))
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
