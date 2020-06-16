class CreateFileModels < ActiveRecord::Migration[6.0]
  def change
    create_table :file_models do |t|
      t.timestamps
    end
  end
end