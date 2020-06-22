class GroupMembership < ApplicationRecord
  attr_accessor :user_id, :group_id
  belongs_to :user
  belongs_to :group
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :group
  enum state: { non_message: 0, not_delivered: 1, delivered: 2, not_responded: 3, not_attending: 4, attending: 5}
end
