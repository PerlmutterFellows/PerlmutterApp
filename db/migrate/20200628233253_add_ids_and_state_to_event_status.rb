class AddIdsAndStateToEventStatus < ActiveRecord::Migration[6.0]
  def change
    add_column :event_statuses, :user_id, :integer, null: false
    add_column :event_statuses, :event_id, :integer, null: false
    add_column :event_statuses, :state, :integer, default: 0
  end
end
