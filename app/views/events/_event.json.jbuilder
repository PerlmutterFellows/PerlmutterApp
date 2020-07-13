json.extract! event, :id, :title, :description, :startDate, :startTime, :endDate, :endTime, :location, :eventType, :published, :to, :created_at, :updated_at, :users, :use_email, :use_call, :use_text, :use_app
json.url event_url(event, format: :json)
