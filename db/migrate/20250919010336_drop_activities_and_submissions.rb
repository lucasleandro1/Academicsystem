class DropActivitiesAndSubmissions < ActiveRecord::Migration[8.0]
  def up
    drop_table :submissions
    drop_table :activities
  end

  def down
    create_table :activities do |t|
      t.references :subject, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.datetime :due_date
      t.references :school, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    create_table :submissions do |t|
      t.references :activity, null: false, foreign_key: true
      t.text :answer
      t.datetime :submission_date
      t.decimal :teacher_grade
      t.text :feedback
      t.references :school, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
