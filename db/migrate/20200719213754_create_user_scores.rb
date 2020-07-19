class CreateUserScores < ActiveRecord::Migration[6.0]
  def change
    create_table :user_scores do |t|
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
