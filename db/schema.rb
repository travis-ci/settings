# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171011140000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "env_vars", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "name"
    t.string "value"
    t.boolean "public", default: false
    t.index ["owner_type", "owner_id"], name: "index_env_vars_on_owner_type_and_owner_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "login"
  end

  create_table "owner_groups", force: :cascade do |t|
    t.string "uuid"
    t.string "owner_type"
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_owner_groups_on_owner_type_and_owner_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "owner_name"
    t.string "name"
    t.index ["owner_type", "owner_id"], name: "index_repositories_on_owner_type_and_owner_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "value"
    t.datetime "expires_at"
    t.text "comment"
    t.index ["owner_type", "owner_id"], name: "index_settings_on_owner_type_and_owner_id"
  end

  create_table "ssh_keys", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.string "description"
    t.index ["owner_type", "owner_id"], name: "index_ssh_keys_on_owner_type_and_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login"
  end

end
