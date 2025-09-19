class RemoveActiveFromTables < ActiveRecord::Migration[8.0]
  def change
    # Remover coluna active das tabelas que a possuem
    remove_column :announcements, :active, :boolean if column_exists?(:announcements, :active)
    remove_column :subjects, :active, :boolean if column_exists?(:subjects, :active)
    remove_column :users, :active, :boolean if column_exists?(:users, :active)
  end
end
