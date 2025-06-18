class CreateSchools < ActiveRecord::Migration[8.0]
  def change
    create_table :schools do |t|
      t.string :name
      t.string :cnpj
      t.string :address
      t.string :phone
      t.string :logo

      t.timestamps
    end
  end
end
