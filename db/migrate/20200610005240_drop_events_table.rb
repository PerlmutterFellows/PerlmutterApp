class DropEventsTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :events
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
