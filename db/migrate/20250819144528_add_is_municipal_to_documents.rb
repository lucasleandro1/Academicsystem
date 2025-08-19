class AddIsMunicipalToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :is_municipal, :boolean
  end
end
