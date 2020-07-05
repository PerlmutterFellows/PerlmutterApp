class CreateEventStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :event_statuses do |t|
      t.timestamps
    end
  end
end
