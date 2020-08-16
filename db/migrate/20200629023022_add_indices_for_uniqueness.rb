class AddIndicesForUniqueness < ActiveRecord::Migration[6.0]
  def change
    add_index :group_memberships, [ :group_id, :user_id ], :unique => true
    add_index :event_statuses, [ :event_id, :user_id ], :unique => true
  end
end
