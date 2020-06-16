class AddReqNullToEvents < ActiveRecord::Migration[6.0]
  def change
    change_column :events, :title, :string, :null => false
    change_column :events, :description, :string, :null => false
    change_column :events, :type, :string, :null => false
    change_column :events, :to, :string, :null => false
    change_column :events, :published, :boolean, :null => false
  end
end
