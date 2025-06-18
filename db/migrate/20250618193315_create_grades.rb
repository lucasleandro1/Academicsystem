class CreateGrades < ActiveRecord::Migration[8.0]
  def change
    create_table :grades do |t|
      t.references :student, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.integer :bimester
      t.decimal :value
      t.string :grade_type

      t.timestamps
    end
  end
end
