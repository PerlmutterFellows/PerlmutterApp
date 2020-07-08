class RemoveAdminBooleanFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :admin
  end
end
