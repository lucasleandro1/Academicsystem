class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :school, null: true, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.string :notification_type, null: false
      t.boolean :read, default: false
      t.datetime :read_at
      t.json :metadata
      t.timestamps
    end

    add_index :notifications, [ :user_id, :read ]
    add_index :notifications, [ :school_id, :notification_type ]
    add_index :notifications, :created_at
  end
end
