class DropAttachments < ActiveRecord::Migration[8.0]
  def up
    drop_table :attachments
  end

  def down
    create_table :attachments do |t|
      t.string :attachable_type, null: false
      t.integer :attachable_id, null: false
      t.references :school, null: false, foreign_key: true
      t.timestamps

      t.index [ :attachable_type, :attachable_id ]
    end
  end
end
