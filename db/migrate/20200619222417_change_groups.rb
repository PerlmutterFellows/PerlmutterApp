class ChangeGroups < ActiveRecord::Migration[6.0]
  def change
    change_table :groups do |t|
      t.boolean :visible, default: true
    end
    change_column_null :groups, :name, false
  end
end
