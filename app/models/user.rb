class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates_uniqueness_of :email, :allow_blank => true, :case_sensitive => false
  validates_uniqueness_of :phone_number, :allow_blank => true, :case_sensitive => false

  def password_required?
    false
  end

  def email_required?
    false
  end

end
