class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.date :start_date
      t.date :end_date
      t.string :visible_to
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
