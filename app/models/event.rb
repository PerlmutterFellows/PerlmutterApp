class Event < ApplicationRecord
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :eventType
  has_many :event_statuses
  has_many :users, :through => :event_statuses, validate: false
  validate :check_users
  validate :check_preferences
  validate :check_length
  enum eventType: %i[event info message]

  private
  def check_users
    if self.users.blank?
      errors.add(:users, I18n.t('global.error_users'))
    end
  end

  def check_preferences
    if !self.use_email? && !self.use_call? && !self.use_text?  && !self.use_app?
      errors.add(:use_email, I18n.t("global.error_preferences"))
      errors.add(:use_call, I18n.t("global.error_preferences"))
      errors.add(:use_text, I18n.t("global.error_preferences"))
      errors.add(:use_app, I18n.t("global.error_preferences"))
    end
  end

  def check_length
    if !self.title.blank? && self.title.length > 100
      errors.add(:title, I18n.t("global.error_length", length: "100"))
    end
    if !self.description.blank? && self.description.length > 500
      errors.add(:description, I18n.t("global.error_length", length: "500"))
    end
    if !self.location.blank? && self.location.length > 300
      errors.add(:location, I18n.t("global.error_length", length: "300"))
    end
  end
end
