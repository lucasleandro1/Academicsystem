class AddFieldsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :is_municipal, :boolean
    add_column :events, :event_type, :string
  end
end
