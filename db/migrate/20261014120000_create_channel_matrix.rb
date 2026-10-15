class CreateChannelMatrix < ActiveRecord::Migration[7.1]
  def change
    create_table :channel_matrix do |t|
      t.integer :account_id, null: false
      t.string :homeserver_url, null: false
      t.string :user_id, null: false
      t.string :as_token, null: false
      t.string :hs_token, null: false
      t.string :sender_localpart, null: false
      t.timestamps
    end
    add_index :channel_matrix, [:account_id, :user_id], unique: true
  end
end
