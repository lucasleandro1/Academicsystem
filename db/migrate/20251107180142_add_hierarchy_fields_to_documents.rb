class AddHierarchyFieldsToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_reference :documents, :recipient, polymorphic: true, null: true
    add_column :documents, :visibility_level, :string, default: 'public'
    add_reference :documents, :attached_by, null: true, foreign_key: { to_table: :users }

    add_index :documents, [ :recipient_type, :recipient_id ]
    add_index :documents, :visibility_level
  end
end
