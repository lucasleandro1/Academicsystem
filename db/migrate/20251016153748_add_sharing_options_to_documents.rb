class AddSharingOptionsToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :sharing_type, :string, default: 'all_students'
    add_reference :documents, :classroom, null: true, foreign_key: true
  end
end
