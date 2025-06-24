class AddRoleFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :registration_number, :string
    add_column :users, :birth_date, :date
    add_column :users, :guardian_name, :string
    add_column :users, :position, :string
    add_column :users, :specialization, :string
  end
end
