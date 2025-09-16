class RemoveOccurrencesTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :occurrences, if_exists: true
  end
end
