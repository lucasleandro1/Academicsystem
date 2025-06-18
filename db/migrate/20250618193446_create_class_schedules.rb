class CreateClassSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :class_schedules do |t|
      t.references :classroom, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.integer :weekday
      t.time :start_time
      t.time :end_time
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
