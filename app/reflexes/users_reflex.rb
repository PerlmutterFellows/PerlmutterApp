# frozen_string_literal: true

class UsersReflex < ApplicationReflex
  # Add Reflex methods in this file.
  #
  # All Reflex instances expose the following properties:
  #
  #   - connection - the ActionCable connection
  #   - channel - the ActionCable channel
  #   - request - an ActionDispatch::Request proxy for the socket connection
  #   - session - the ActionDispatch::Session store for the current visitor
  #   - url - the URL of the page that triggered the reflex
  #   - element - a Hash like object that represents the HTML element that triggered the reflex
  #   - params - parameters from the element's closest form (if any)
  #
  # Example:
  #
  #   def example(argument=true)
  #     # Your logic here...
  #     # Any declared instance variables will be made available to the Rails controller and view.
  #   end
  #
  # Learn more at: https://docs.stimulusreflex.com
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

  def reset_filters
    queries = [:name_query, :group_query, :email_query, :phone_number_query]
    queries.each { |query| session[query] = nil }
  end

end
