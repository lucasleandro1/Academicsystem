class AddGuardianPhoneToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :guardian_phone, :string
  end
end
