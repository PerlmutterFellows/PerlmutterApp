class AddStateToMembership < ActiveRecord::Migration[6.0]
  def change
    add_column :group_memberships, :state, :integer, default: 0, null: false
  end
end
