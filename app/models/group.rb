class Group < ApplicationRecord
  has_many :group_memberships
  has_many :users, :through => :group_memberships
  validates_presence_of :name
end
