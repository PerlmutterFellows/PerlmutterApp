class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable
  enum role: %i[user moderator admin]
  has_many :group_memberships
  has_many :groups, :through => :group_memberships
  has_many :event_statuses
  has_many :events, :through => :event_statuses
  has_many :user_scores
  has_many :subscores, :through => :user_scores
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_confirmation_of :password
  validate :check_if_email_or_phone_entered?
  validate :format_phone_number
  validates_uniqueness_of :phone_number, conditions: -> {where.not(:phone_number => '')}
  after_save :send_phone_confirmation
  include ApplicationHelper
  include RegistrationsHelper

  def email_required?
    false
  end

  def check_if_email_or_phone_entered?
    if self.email.blank? && self.phone_number.blank?
      errors.add(:email, I18n.t("global.error_email_or_phone"))
      errors.add(:phone_number, I18n.t("global.error_email_or_phone"))
    end
    if !self.use_email? && !self.use_call? && !self.use_text?
      errors.add(:use_email, I18n.t("global.error_preferences"))
      errors.add(:use_call, I18n.t("global.error_preferences"))
      errors.add(:use_text, I18n.t("global.error_preferences"))
    end
    if self.email.blank? && self.use_email?
      errors.add(:email, I18n.t("global.error_email"))
    end
    if self.phone_number.blank? && (self.use_call? || self.use_text?)
      errors.add(:phone_number, I18n.t("global.error_phone"))
    end
  end

  def get_locale
    yielded_locale = yield_locale_from_available(self.locale)
    yielded_locale.blank? ? I18n.locale : yielded_locale
  end

  def confirmed_text?
    !self.text_confirmation_sent_at.blank? && !self.text_confirmed_at.blank?
  end

  def confirmed_call?
    !self.call_confirmation_sent_at.blank? && !self.call_confirmed_at.blank?
  end

  def skip_confirmation_text!
    self.text_confirmation_sent_at = DateTime.now
    self.text_confirmed_at = DateTime.now
  end

  def skip_confirmation_call!
    self.call_confirmation_sent_at = DateTime.now
    self.call_confirmed_at = DateTime.now
  end

  def skip_confirmation_all!
    self.skip_confirmation!
    self.skip_confirmation_text!
    self.skip_confirmation_call!
  end

  private

  def format_phone_number
    unless phone_number.blank?
      valid_number, error = TwilioHandler.new.get_valid_phone_number(phone_number)
      if error.blank?
        self.phone_number = valid_number
      elsif error.include? "20003"
        errors.add(:phone_number, I18n.t('global.twilio_down'))
      else
        errors.add(:phone_number, I18n.t('global.invalid_input'))
      end
    end
  end

  def send_phone_confirmation
    if use_text? && self.text_confirmation_sent_at.blank?
      send_confirmation_phone(self, true)
    end
    if use_call? && self.call_confirmation_sent_at.blank?
      send_confirmation_phone(self, false)
    end
  end

end
