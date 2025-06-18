class CreateOccurrences < ActiveRecord::Migration[8.0]
  def change
    create_table :occurrences do |t|
      t.references :student, null: false, foreign_key: true
      t.text :description
      t.string :occurrence_type
      t.references :author, polymorphic: true, null: false
      t.date :date
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
