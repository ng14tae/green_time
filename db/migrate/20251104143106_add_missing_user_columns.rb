class AddMissingUserColumns < ActiveRecord::Migration[7.0]
  def change
    # 存在しない場合のみ追加（安全な方法）
    add_column :users, :line_user_id, :string unless column_exists?(:users, :line_user_id)
    add_column :users, :nickname, :string unless column_exists?(:users, :nickname)
    add_column :users, :avatar_url, :string unless column_exists?(:users, :avatar_url)

    # インデックス
    add_index :users, :line_user_id, unique: true unless index_exists?(:users, :line_user_id)
  end
end
