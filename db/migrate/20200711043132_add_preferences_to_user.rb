class AddPreferencesToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :use_email, :boolean, default: false
    add_column :users, :use_text, :boolean, default: false
    add_column :users, :use_call, :boolean, default: false
  end
end
