class AddNotifyFlag < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :notify, :boolean, null: false, default: false
  end
end
