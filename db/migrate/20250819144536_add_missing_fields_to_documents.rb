class AddMissingFieldsToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :file_path, :string
    add_column :documents, :file_name, :string
  end
end
