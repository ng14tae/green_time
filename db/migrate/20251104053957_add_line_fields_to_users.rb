class AddLineFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :line_user_id, :string
    add_column :users, :avatar_url, :string
    add_column :users, :nickname, :string
  end
end
