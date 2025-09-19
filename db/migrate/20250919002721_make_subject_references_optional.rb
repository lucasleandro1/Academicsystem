class MakeSubjectReferencesOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :subjects, :classroom_id, true
    change_column_null :subjects, :user_id, true
  end
end
