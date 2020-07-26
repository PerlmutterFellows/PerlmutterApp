class CreateSubscores < ActiveRecord::Migration[6.0]
  def change
    create_table :subscores do |t|
      t.integer :user_score_id, null: false
      t.string :name, null: false
      t.decimal :score, precision: 10, scale: 2, null: false
      t.decimal :max_score, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
