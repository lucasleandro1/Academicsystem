class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :subject, null: false, foreign_key: true
      t.references :teacher, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.datetime :due_date
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
