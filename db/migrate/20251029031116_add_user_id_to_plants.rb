class AddUserIdToPlants < ActiveRecord::Migration[7.2]
  def change
    add_reference :plants, :user, null: true, foreign_key: true
  end
end
