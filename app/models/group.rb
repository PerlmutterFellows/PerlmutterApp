class Group < ApplicationRecord
  has_many :group_memberships
  has_many :users, :through => :group_memberships, validate: false
  validate :check_users
  validates_presence_of :name

  private
  def check_users
    if self.users.blank?
      errors.add(:users, I18n.t('global.error_users'))
    end
  end
end
