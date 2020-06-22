class CreateGroupMemberships < ActiveRecord::Migration[6.0]
  def change
    create_table :group_memberships do |t|

      t.timestamps
    end
  end
end
