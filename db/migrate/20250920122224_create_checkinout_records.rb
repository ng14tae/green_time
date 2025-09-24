class CreateCheckinoutRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :checkinout_records do |t|
      t.bigint :user_id, null: false
      t.timestamp :checkin_time, null: false
      t.timestamp :checkout_time

      t.timestamps
    end

    # インデックスと外部キー制約
    add_index :checkinout_records, :user_id
    add_foreign_key :checkinout_records, :users
  end
end
