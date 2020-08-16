class RemoveEventIdFromGroups < ActiveRecord::Migration[6.0]
  def change
    remove_column :groups, :event_id
  end
end
