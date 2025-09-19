class RemoveVisibleToFromEvents < ActiveRecord::Migration[8.0]
  def change
    remove_column :events, :visible_to, :string
  end
end
