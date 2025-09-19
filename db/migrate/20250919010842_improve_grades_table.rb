class ImproveGradesTable < ActiveRecord::Migration[8.0]
  def change
    add_column :grades, :assessment_name, :string
    add_column :grades, :assessment_date, :date
    add_column :grades, :max_value, :decimal, precision: 5, scale: 2
    add_column :grades, :teacher_notes, :text
    add_column :grades, :school_id, :integer
    add_foreign_key :grades, :schools
    add_index :grades, :school_id

    # Alterando o campo value para ter precision específica
    change_column :grades, :value, :decimal, precision: 5, scale: 2
  end
end
