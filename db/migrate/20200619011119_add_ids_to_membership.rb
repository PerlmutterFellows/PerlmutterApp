class AddIdsToMembership < ActiveRecord::Migration[6.0]
  def change
    add_column :group_memberships, :user_id, :integer, null: false
    add_column :group_memberships, :group_id, :integer, null: false
  end
end
