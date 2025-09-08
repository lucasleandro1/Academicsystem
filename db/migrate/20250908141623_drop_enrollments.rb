class DropEnrollments < ActiveRecord::Migration[8.0]
  def change
    drop_table :enrollments do |t|
      t.integer "classroom_id", null: false
      t.string "status"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "user_id", null: false
      t.index [ "classroom_id" ], name: "index_enrollments_on_classroom_id"
      t.index [ "user_id" ], name: "index_enrollments_on_user_id"
    end
  end
end
