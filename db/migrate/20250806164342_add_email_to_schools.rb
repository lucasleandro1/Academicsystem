class AddEmailToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :email, :string
  end
end
