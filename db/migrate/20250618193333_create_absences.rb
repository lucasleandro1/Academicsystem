class CreateAbsences < ActiveRecord::Migration[8.0]
  def change
    create_table :absences do |t|
      t.references :student, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.date :date
      t.boolean :justified

      t.timestamps
    end
  end
end
