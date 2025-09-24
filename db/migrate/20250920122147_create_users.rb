class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :line_user_id, null: false
      t.string :display_name
      t.string :avatar_url
      t.bigint :plant_id
      t.string :nickname

      t.timestamps
    end

    # インデックス追加
    add_index :users, :line_user_id, unique: true
    add_index :users, :plant_id
  end
end
