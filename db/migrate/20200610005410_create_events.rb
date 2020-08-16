class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.date :startDate
      t.time :startTime
      t.date :endDate
      t.time :endTime
      t.string :location
      t.integer :eventType, null: false, default: 0
      t.boolean :published, null: false, default: false
      t.string :to, null: false

      t.timestamps
    end
  end
end
