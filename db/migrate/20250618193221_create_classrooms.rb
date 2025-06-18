class CreateClassrooms < ActiveRecord::Migration[8.0]
  def change
    create_table :classrooms do |t|
      t.string :name
      t.integer :academic_year
      t.string :shift
      t.string :level
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
