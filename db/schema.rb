# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151130184809) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "matches", force: :cascade do |t|
    t.boolean  "over",       default: false, null: false
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hand_size",  default: 5
    t.text     "game"
  end

  create_table "matches_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "match_id"
  end

  add_index "matches_users", ["match_id"], name: "index_matches_users_on_match_id", using: :btree
  add_index "matches_users", ["user_id"], name: "index_matches_users_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "type"
    t.integer  "think_time"
  end

end
