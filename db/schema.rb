ActiveRecord::Schema[7.2].define(version: 2025_09_29_060107) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "checkinout_records", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "checkin_time", precision: nil, null: false
    t.datetime "checkout_time", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_checkinout_records_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "checkinout_records", "users"
end
