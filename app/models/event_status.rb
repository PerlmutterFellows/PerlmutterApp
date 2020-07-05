class EventStatus < ApplicationRecord
  belongs_to :user
  belongs_to :event
  enum state: %i[non_message not_delivered delivered not_responded not_attending attending]
  validates_uniqueness_of :user_id, scope: :event_id
end
