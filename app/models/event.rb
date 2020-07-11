class Event < ApplicationRecord
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :eventType
  has_many :event_statuses
  has_many :users, :through => :event_statuses, validate: false
  validate :check_users
  validate :check_preferences
  enum eventType: %i[event info message]

  private
  def check_users
    if self.users.blank?
      errors.add(:users, I18n.t('global.error_users'))
    end
  end

  def check_preferences
    if !self.use_email? && !self.use_call? && !self.use_text?  && !self.use_app?
      errors.add(:use_email, "must select contact preferences!")
      errors.add(:use_text, "must select contact preferences!")
      errors.add(:use_call, "must select contact preferences!")
      errors.add(:use_app, "must select contact preferences!")
    end
  end
end
