class CreatePlants < ActiveRecord::Migration[7.2]
  def change
    create_table :plants do |t|
      t.string :plant_name

      t.timestamps
    end
  end
end
