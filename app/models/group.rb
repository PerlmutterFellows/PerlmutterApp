class Group < ApplicationRecord
  has_many :group_memberships
  has_many :users, :through => :group_memberships, validate: false
  validate :check_users
  validates_presence_of :name

  scope :search_by_name, ->(query) {
    if query.present?
      query = sanitize_sql_like(query).downcase
      where(arel_table[:name].matches("%#{query}%"))
    end
  }

  scope :search_by_user, ->(query) {
    if query.present?
      query = sanitize_sql_like(query).downcase
      includes(:users).references(:users).where("lower(users.first_name) LIKE ?", "%#{query}%")
          .or(includes(:users).references(:users).where("lower(users.last_name) LIKE ?", "%#{query}%"))
          .or(includes(:users).references(:users).where("concat(lower(users.first_name), ' ', lower(users.last_name)) LIKE ?", "%#{query}%"))
    end
  }

  def self.filter(group_name_query, user_name_query)
    search_by_name(group_name_query).search_by_user(user_name_query)
  end

  private
  def check_users
    if self.users.blank?
      errors.add(:users, I18n.t('global.error_users'))
    end
  end
end
