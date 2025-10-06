class CreateMoods < ActiveRecord::Migration[7.0]
  def change
    create_table :moods do |t|
      t.references :user, foreign_key: true
      t.references :checkinout_record, foreign_key: true
      t.string :feeling    # ← 任意の気分（例："happy", "sad" など）
      t.string :comment    # ← 140文字程度のメモ欄（任意）

      t.timestamps
    end
  end
end
