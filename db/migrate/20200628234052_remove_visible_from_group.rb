class RemoveVisibleFromGroup < ActiveRecord::Migration[6.0]
  def change
    remove_column :groups, :visible
  end
end
