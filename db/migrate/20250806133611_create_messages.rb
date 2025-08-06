class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :school, null: false, foreign_key: true
      t.string :subject, null: false
      t.text :body, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, [ :recipient_id, :read_at ]
    add_index :messages, [ :sender_id, :created_at ]
  end
end
