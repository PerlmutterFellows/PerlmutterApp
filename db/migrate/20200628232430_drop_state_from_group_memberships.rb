class DropStateFromGroupMemberships < ActiveRecord::Migration[6.0]
  def change
    remove_column :group_memberships, :state
  end
end
