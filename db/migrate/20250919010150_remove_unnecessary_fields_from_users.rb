class RemoveUnnecessaryFieldsFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :position, :string
    remove_column :users, :specialization, :string
    remove_column :users, :registration_number, :string
  end
end
