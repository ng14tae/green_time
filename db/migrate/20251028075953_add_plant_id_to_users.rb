class AddPlantIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :plant, foreign_key: true, null: true
  end
end
