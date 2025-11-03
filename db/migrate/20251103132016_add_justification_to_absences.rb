class AddJustificationToAbsences < ActiveRecord::Migration[8.0]
  def change
    add_column :absences, :justification, :text
  end
end
