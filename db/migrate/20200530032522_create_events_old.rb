class CreateEventsOld < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :title
      t.string :description
      t.datetime :datetime
      t.string :type
      t.string :to
      t.boolean :published

      t.timestamps
    end
    create_table :file_models do |t|
      t.timestamps
    end
  end
end