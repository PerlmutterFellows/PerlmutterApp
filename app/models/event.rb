class Event < ApplicationRecord
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :eventType
  has_one :group
  enum eventType: { event: 0, info: 1, message: 2}
end
