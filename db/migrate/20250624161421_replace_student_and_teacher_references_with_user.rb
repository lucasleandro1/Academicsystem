class ReplaceStudentAndTeacherReferencesWithUser < ActiveRecord::Migration[8.0]
  def change
    remove_reference :absences, :student, foreign_key: true
    remove_reference :activities, :teacher, foreign_key: true
    remove_reference :documents, :student, foreign_key: true
    remove_reference :documents, :teacher, foreign_key: true
    remove_reference :enrollments, :student, foreign_key: true
    remove_reference :grades, :student, foreign_key: true
    remove_reference :occurrences, :student, foreign_key: true
    remove_reference :submissions, :student, foreign_key: true
    remove_reference :subjects, :teacher, foreign_key: true

    add_reference :absences, :user, null: false, foreign_key: true
    add_reference :activities, :user, null: false, foreign_key: true
    add_reference :documents, :user, null: false, foreign_key: true
    add_reference :enrollments, :user, null: false, foreign_key: true
    add_reference :grades, :user, null: false, foreign_key: true
    add_reference :occurrences, :user, null: false, foreign_key: true
    add_reference :submissions, :user, null: false, foreign_key: true
    add_reference :subjects, :user, null: false, foreign_key: true
  end
end
