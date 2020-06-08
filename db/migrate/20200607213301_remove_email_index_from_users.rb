class RemoveEmailIndexFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_index :users, :email
    add_index :users, :email
  end
end
