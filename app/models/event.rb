class Event < ApplicationRecord
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :eventType
  has_many :event_statuses
  has_many :users, :through => :event_statuses
  enum eventType: %i[event info message]
end
