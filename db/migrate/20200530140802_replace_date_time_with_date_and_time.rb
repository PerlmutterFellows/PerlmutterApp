class ReplaceDateTimeWithDateAndTime < ActiveRecord::Migration[6.0]
  def change
    remove_column :events, :datetime
    add_column :events, :date, :date
    add_column :events, :time, :time
  end
end
