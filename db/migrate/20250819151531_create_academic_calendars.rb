class CreateAcademicCalendars < ActiveRecord::Migration[8.0]
  def change
    create_table :academic_calendars do |t|
      t.string :title
      t.date :date
      t.string :calendar_type
      t.text :description
      t.boolean :all_schools
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
