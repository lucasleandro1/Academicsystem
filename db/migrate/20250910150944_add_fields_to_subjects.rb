class AddFieldsToSubjects < ActiveRecord::Migration[8.0]
  def change
    add_column :subjects, :code, :string
    add_column :subjects, :area, :string
    add_column :subjects, :description, :text
    add_column :subjects, :active, :boolean, default: true
    add_column :subjects, :allows_makeup_exams, :boolean, default: true
  end
end
