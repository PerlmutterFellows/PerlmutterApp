# frozen_string_literal: true

class UsersReflex < ApplicationReflex
  include UsersHelper
  def search_by_name
    session[:name_query] = element[:value].strip
  end

  def search_by_groups
    session[:group_query] = element[:value].strip
  end

  def search_by_phone
    session[:phone_number_query] = element[:value].strip
  end

  def search_by_email
    session[:email_query] = element[:value].strip
  end

  def search_by_date
    session[:date_query] = element[:value].strip
  end

  def reset_filters_reflex
    reset_filters
  end

end
