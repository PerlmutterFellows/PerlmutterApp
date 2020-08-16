class AddNewFieldsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :role, :integer, default: 0
    add_column :users, :locale, :string, default: "en"
  end
end
