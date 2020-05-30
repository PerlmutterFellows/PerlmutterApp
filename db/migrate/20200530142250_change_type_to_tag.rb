class ChangeTypeToTag < ActiveRecord::Migration[6.0]
  def change
    rename_column :events, :type, :tag
  end
end
