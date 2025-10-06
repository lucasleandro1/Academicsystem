# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_19_011116) do
  create_table "absences", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.date "date"
    t.boolean "justified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["subject_id"], name: "index_absences_on_subject_id"
    t.index ["user_id"], name: "index_absences_on_user_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.string "title"
    t.date "date"
    t.string "calendar_type"
    t.text "description"
    t.boolean "all_schools"
    t.integer "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_calendars_on_school_id"
  end

  create_table "class_schedules", force: :cascade do |t|
    t.integer "classroom_id", null: false
    t.integer "subject_id", null: false
    t.integer "school_id", null: false
    t.integer "weekday", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.string "period"
    t.integer "class_order"
    t.boolean "active", default: true
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id", "weekday", "start_time", "end_time"], name: "unique_classroom_schedule", unique: true
    t.index ["classroom_id", "weekday", "start_time"], name: "index_class_schedules_on_classroom_weekday_time"
    t.index ["classroom_id"], name: "index_class_schedules_on_classroom_id"
    t.index ["school_id", "weekday"], name: "index_class_schedules_on_school_weekday"
    t.index ["school_id"], name: "index_class_schedules_on_school_id"
    t.index ["subject_id", "weekday"], name: "index_class_schedules_on_subject_weekday"
    t.index ["subject_id"], name: "index_class_schedules_on_subject_id"
  end

  create_table "classrooms", force: :cascade do |t|
    t.string "name"
    t.integer "academic_year"
    t.string "shift"
    t.string "level"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_classrooms_on_school_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "title"
    t.string "document_type"
    t.text "description"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.boolean "is_municipal"
    t.string "file_path"
    t.string "file_name"
    t.index ["school_id"], name: "index_documents_on_school_id"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_municipal"
    t.string "event_type"
    t.date "event_date"
    t.time "start_time"
    t.time "end_time"
    t.index ["school_id"], name: "index_events_on_school_id"
  end

  create_table "grades", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.integer "bimester"
    t.decimal "value", precision: 5, scale: 2
    t.string "grade_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "assessment_name"
    t.date "assessment_date"
    t.decimal "max_value", precision: 5, scale: 2
    t.text "teacher_notes"
    t.integer "school_id"
    t.index ["school_id"], name: "index_grades_on_school_id"
    t.index ["subject_id"], name: "index_grades_on_subject_id"
    t.index ["user_id"], name: "index_grades_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "sender_id", null: false
    t.integer "recipient_id", null: false
    t.integer "school_id", null: false
    t.string "subject", null: false
    t.text "body", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id", "read_at"], name: "index_messages_on_recipient_id_and_read_at"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["school_id"], name: "index_messages_on_school_id"
    t.index ["sender_id", "created_at"], name: "index_messages_on_sender_id_and_created_at"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.string "cnpj"
    t.string "address"
    t.string "phone"
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.integer "classroom_id"
    t.integer "workload"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "code"
    t.string "area"
    t.text "description"
    t.boolean "allows_makeup_exams", default: true
    t.index ["classroom_id"], name: "index_subjects_on_classroom_id"
    t.index ["school_id"], name: "index_subjects_on_school_id"
    t.index ["user_id"], name: "index_subjects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "user_type"
    t.integer "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.date "birth_date"
    t.string "guardian_name"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.integer "classroom_id"
    t.index ["classroom_id"], name: "index_users_on_classroom_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
  end

  add_foreign_key "absences", "subjects"
  add_foreign_key "absences", "users"
  add_foreign_key "calendars", "schools"
  add_foreign_key "class_schedules", "classrooms"
  add_foreign_key "class_schedules", "schools"
  add_foreign_key "class_schedules", "subjects"
  add_foreign_key "classrooms", "schools"
  add_foreign_key "documents", "schools"
  add_foreign_key "documents", "users"
  add_foreign_key "events", "schools"
  add_foreign_key "grades", "schools"
  add_foreign_key "grades", "subjects"
  add_foreign_key "grades", "users"
  add_foreign_key "messages", "schools"
  add_foreign_key "messages", "users", column: "recipient_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "subjects", "classrooms"
  add_foreign_key "subjects", "schools"
  add_foreign_key "subjects", "users"
  add_foreign_key "users", "classrooms"
end
