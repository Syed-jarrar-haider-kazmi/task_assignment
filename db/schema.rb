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

ActiveRecord::Schema[7.2].define(version: 2025_07_09_184331) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ip_activities", force: :cascade do |t|
    t.string "ip_address", null: false
    t.bigint "user_id"
    t.integer "owning_user_id"
    t.string "trading_account_login"
    t.integer "activity_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_type", "created_at"], name: "index_ip_activities_on_type_and_created_at", order: { created_at: :desc }
    t.index ["user_id"], name: "index_ip_activities_on_user_id"
  end

  create_table "ip_addresses", primary_key: "address", id: :string, force: :cascade do |t|
    t.string "region"
    t.string "country"
    t.string "city"
    t.float "lat"
    t.float "lon"
    t.boolean "is_vpn", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trading_accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "login", null: false
    t.integer "phase", default: 0, null: false
    t.integer "platform", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["login"], name: "index_trading_accounts_on_login", unique: true
    t.index ["user_id"], name: "index_trading_accounts_on_user_id"
  end

  create_table "universal_filters", force: :cascade do |t|
    t.string "name"
    t.string "filterable_type"
    t.bigint "filterable_id"
    t.string "target_model", null: false
    t.jsonb "filter_params", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["filterable_type", "filterable_id"], name: "index_universal_filters_on_filterable_type_and_filterable_id"
    t.index ["target_model"], name: "index_universal_filters_on_target_model"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "ip_activities", "ip_addresses", column: "ip_address", primary_key: "address"
  add_foreign_key "ip_activities", "trading_accounts", column: "trading_account_login", primary_key: "login"
  add_foreign_key "ip_activities", "users"
  add_foreign_key "ip_activities", "users", column: "owning_user_id"
  add_foreign_key "trading_accounts", "users"
end
