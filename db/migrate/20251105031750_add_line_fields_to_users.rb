class AddLineFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :display_name, :string unless column_exists?(:users, :display_name)
  end
end
