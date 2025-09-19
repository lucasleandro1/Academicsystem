class DropNotifications < ActiveRecord::Migration[8.0]
  def up
    drop_table :notifications
  end

  def down
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :school, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.string :notification_type, null: false
      t.boolean :read, default: false
      t.datetime :read_at
      t.json :metadata
      t.timestamps

      t.index [ :user_id, :read ]
      t.index [ :school_id, :notification_type ]
      t.index :created_at
    end
  end
end
