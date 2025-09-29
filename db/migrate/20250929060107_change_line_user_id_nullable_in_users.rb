class ChangeLineUserIdNullableInUsers < ActiveRecord::Migration[7.0]
  def change
    if column_exists?(:users, :line_user_id)
      change_column_null :users, :line_user_id, true
    end
  end
end
