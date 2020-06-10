json.extract! event, :id, :title, :description, :startDate, :startTime, :endDate, :endTime, :location, :eventType, :published, :to, :created_at, :updated_at
json.url event_url(event, format: :json)
