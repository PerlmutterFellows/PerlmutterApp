class AddLastnameToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :last_name, :string, null: false, default: ""
  end
end
