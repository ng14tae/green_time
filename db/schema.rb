# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_11_04_143106) do
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

  create_table "moods", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "checkinout_record_id"
    t.string "feeling"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checkinout_record_id"], name: "index_moods_on_checkinout_record_id"
    t.index ["user_id"], name: "index_moods_on_user_id"
  end

  create_table "plants", force: :cascade do |t|
    t.string "plant_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_plants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "plant_id"
    t.string "line_user_id"
    t.string "nickname"
    t.string "avatar_url"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["line_user_id"], name: "index_users_on_line_user_id", unique: true
    t.index ["plant_id"], name: "index_users_on_plant_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "checkinout_records", "users"
  add_foreign_key "moods", "checkinout_records"
  add_foreign_key "moods", "users"
  add_foreign_key "plants", "users"
  add_foreign_key "users", "plants"
end
