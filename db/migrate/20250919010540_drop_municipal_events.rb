class DropMunicipalEvents < ActiveRecord::Migration[8.0]
  def up
    drop_table :municipal_events
  end

  def down
    create_table :municipal_events do |t|
      t.string :title
      t.text :description
      t.string :event_type
      t.datetime :start_date
      t.datetime :end_date
      t.string :location
      t.references :user, null: false, foreign_key: true
      t.text :schools_participating
      t.boolean :registration_required
      t.integer :max_participants
      t.timestamps
    end
  end
end
