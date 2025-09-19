class DropAnnouncements < ActiveRecord::Migration[8.0]
  def up
    drop_table :announcements
  end

  def down
    create_table :announcements do |t|
      t.string :title
      t.text :content
      t.string :announcement_type
      t.text :target_schools
      t.references :user, null: false, foreign_key: true
      t.integer :priority
      t.datetime :published_at
      t.datetime :expires_at
      t.timestamps
    end
  end
end
