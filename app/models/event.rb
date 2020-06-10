class Event < ApplicationRecord
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :eventType
  validates_presence_of :to
  enum eventType: { event: 0, info: 1, message: 2}
end
