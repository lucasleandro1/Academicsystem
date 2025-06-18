class CreateSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :submissions do |t|
      t.references :activity, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.text :answer
      t.datetime :submission_date
      t.decimal :teacher_grade
      t.text :feedback
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
