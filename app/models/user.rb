class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_one_attached :csv_file
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_confirmation_of :password
  validate :check_if_email_or_phone_entered?
  validates_uniqueness_of :phone_number, conditions: -> {where.not(:phone_number => '')}

  def password_required?
    false
  end

  def email_required?
    false
  end

  def check_if_email_or_phone_entered?
    if email.blank? && phone_number.blank?
      errors.add(:email, "must have an email or a phone number!")
    end
  end

end
