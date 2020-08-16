class RemoveToFromEvent < ActiveRecord::Migration[6.0]
  def change
    remove_column :events, :to
  end
end
