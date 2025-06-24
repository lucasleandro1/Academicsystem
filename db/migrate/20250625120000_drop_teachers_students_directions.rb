class DropTeachersStudentsDirections < ActiveRecord::Migration[8.0]
  def change
    drop_table :teachers
    drop_table :students
    drop_table :directions
  end
end
