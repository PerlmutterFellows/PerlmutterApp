require 'cgi'

class StaticPagesController < ApplicationController
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
end
