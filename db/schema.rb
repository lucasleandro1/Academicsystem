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

ActiveRecord::Schema[8.0].define(version: 2025_08_19_175937) do
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

  create_table "activities", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.string "title"
    t.text "description"
    t.datetime "due_date"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["school_id"], name: "index_activities_on_school_id"
    t.index ["subject_id"], name: "index_activities_on_subject_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "announcements", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "announcement_type"
    t.text "target_schools"
    t.integer "user_id", null: false
    t.integer "priority"
    t.datetime "published_at"
    t.datetime "expires_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_announcements_on_user_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.string "attachable_type", null: false
    t.integer "attachable_id", null: false
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable"
    t.index ["school_id"], name: "index_attachments_on_school_id"
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
    t.integer "weekday"
    t.time "start_time"
    t.time "end_time"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_class_schedules_on_classroom_id"
    t.index ["school_id"], name: "index_class_schedules_on_school_id"
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

  create_table "enrollments", force: :cascade do |t|
    t.integer "classroom_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["classroom_id"], name: "index_enrollments_on_classroom_id"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.string "visible_to"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_municipal"
    t.string "event_type"
    t.date "event_date"
    t.index ["school_id"], name: "index_events_on_school_id"
  end

  create_table "grades", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.integer "bimester"
    t.decimal "value"
    t.string "grade_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
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

  create_table "municipal_events", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "event_type"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "location"
    t.integer "user_id", null: false
    t.text "schools_participating"
    t.boolean "registration_required"
    t.integer "max_participants"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_municipal_events_on_user_id"
  end

  create_table "occurrences", force: :cascade do |t|
    t.text "description"
    t.string "occurrence_type"
    t.string "author_type", null: false
    t.integer "author_id", null: false
    t.date "date"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["author_type", "author_id"], name: "index_occurrences_on_author"
    t.index ["school_id"], name: "index_occurrences_on_school_id"
    t.index ["user_id"], name: "index_occurrences_on_user_id"
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
    t.integer "classroom_id", null: false
    t.integer "workload"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["classroom_id"], name: "index_subjects_on_classroom_id"
    t.index ["school_id"], name: "index_subjects_on_school_id"
    t.index ["user_id"], name: "index_subjects_on_user_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer "activity_id", null: false
    t.text "answer"
    t.datetime "submission_date"
    t.decimal "teacher_grade"
    t.text "feedback"
    t.integer "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["activity_id"], name: "index_submissions_on_activity_id"
    t.index ["school_id"], name: "index_submissions_on_school_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "user_type"
    t.integer "school_id"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.string "registration_number"
    t.date "birth_date"
    t.string "guardian_name"
    t.string "position"
    t.string "specialization"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
  end

  add_foreign_key "absences", "subjects"
  add_foreign_key "absences", "users"
  add_foreign_key "activities", "schools"
  add_foreign_key "activities", "subjects"
  add_foreign_key "activities", "users"
  add_foreign_key "announcements", "users"
  add_foreign_key "attachments", "schools"
  add_foreign_key "calendars", "schools"
  add_foreign_key "class_schedules", "classrooms"
  add_foreign_key "class_schedules", "schools"
  add_foreign_key "class_schedules", "subjects"
  add_foreign_key "classrooms", "schools"
  add_foreign_key "documents", "schools"
  add_foreign_key "documents", "users"
  add_foreign_key "enrollments", "classrooms"
  add_foreign_key "enrollments", "users"
  add_foreign_key "events", "schools"
  add_foreign_key "grades", "subjects"
  add_foreign_key "grades", "users"
  add_foreign_key "messages", "schools"
  add_foreign_key "messages", "users", column: "recipient_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "municipal_events", "users"
  add_foreign_key "occurrences", "schools"
  add_foreign_key "occurrences", "users"
  add_foreign_key "subjects", "classrooms"
  add_foreign_key "subjects", "schools"
  add_foreign_key "subjects", "users"
  add_foreign_key "submissions", "activities"
  add_foreign_key "submissions", "schools"
  add_foreign_key "submissions", "users"
end
