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

ActiveRecord::Schema.define(version: 20170120190619) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channels", force: :cascade do |t|
    t.string   "slack_id",             null: false
    t.string   "name",                 null: false
    t.string   "default_repositories", null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["slack_id"], name: "index_channels_on_slack_id", unique: true, using: :btree
  end

  create_table "repo_lists", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_repo_lists_on_name", unique: true, using: :btree
  end

  create_table "repositories", force: :cascade do |t|
    t.string   "name",         null: false
    t.integer  "repo_list_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["name", "repo_list_id"], name: "index_repositories_on_name_and_repo_list_id", unique: true, using: :btree
    t.index ["repo_list_id"], name: "index_repositories_on_repo_list_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.bigint   "github_id",     null: false
    t.string   "github_token",  null: false
    t.string   "github_handle", null: false
    t.string   "slack_id",      null: false
    t.string   "slack_handle",  null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["github_id"], name: "index_users_on_github_id", unique: true, using: :btree
    t.index ["slack_id"], name: "index_users_on_slack_id", unique: true, using: :btree
  end

  add_foreign_key "repositories", "repo_lists"
end
