class AddEventIdToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :event_id, :integer
  end
end
