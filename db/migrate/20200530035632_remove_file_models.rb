class RemoveFileModels < ActiveRecord::Migration[6.0]
  def up
    drop_table :file_models
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
