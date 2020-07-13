class AddPreferencesToEvent < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :use_email, :boolean, default: false
    add_column :events, :use_text, :boolean, default: false
    add_column :events, :use_call, :boolean, default: false
    add_column :events, :use_app, :boolean, default: false
  end
end
