class AddClassroomToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :classroom, null: true, foreign_key: true
  end
end
