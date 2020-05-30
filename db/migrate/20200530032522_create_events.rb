class CreateEvents < ActiveRecord::Migration[6.0]
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
  end
end
