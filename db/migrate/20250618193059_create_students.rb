class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.references :user, null: false, foreign_key: true
      t.string :registration_number
      t.date :birth_date
      t.string :guardian_name

      t.timestamps
    end
  end
end
