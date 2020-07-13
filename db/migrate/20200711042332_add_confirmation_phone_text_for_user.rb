class AddConfirmationPhoneTextForUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :text_confirmed_at, :datetime
    add_column :users, :text_confirmation_sent_at, :datetime
    add_column :users, :call_confirmed_at, :datetime
    add_column :users, :call_confirmation_sent_at, :datetime
  end
end
