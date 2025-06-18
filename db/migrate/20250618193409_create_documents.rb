class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :title
      t.string :document_type
      t.text :description
      t.references :student, null: false, foreign_key: true
      t.references :teacher, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
