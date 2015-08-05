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

ActiveRecord::Schema.define(version: 20150804151329) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "builds", force: :cascade do |t|
    t.string   "version"
    t.boolean  "success"
    t.string   "source"
    t.datetime "event_created_at"
  end

  create_table "deploys", force: :cascade do |t|
    t.string   "app_name"
    t.string   "server"
    t.string   "version"
    t.string   "deployed_by"
    t.datetime "event_created_at"
  end

  create_table "event_counts", force: :cascade do |t|
    t.string  "snapshot_name"
    t.integer "event_id"
  end

  create_table "events", force: :cascade do |t|
    t.json     "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "type"
  end

  create_table "feature_reviews", force: :cascade do |t|
    t.string "url"
    t.string "versions", array: true
  end

  create_table "manual_tests", force: :cascade do |t|
    t.string   "email"
    t.string   "versions",   array: true
    t.boolean  "accepted"
    t.text     "comment"
    t.datetime "created_at"
  end

  create_table "repository_locations", force: :cascade do |t|
    t.string   "uri"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "remote_head"
  end

  add_index "repository_locations", ["name"], name: "index_repository_locations_on_name", unique: true, using: :btree

  create_table "tickets", force: :cascade do |t|
    t.string   "key"
    t.string   "summary"
    t.string   "status"
    t.text     "urls",             array: true
    t.datetime "event_created_at"
  end

  create_table "tokens", force: :cascade do |t|
    t.string   "source"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  add_index "tokens", ["value"], name: "index_tokens_on_value", unique: true, using: :btree

  create_table "uatests", force: :cascade do |t|
    t.string   "server"
    t.boolean  "success"
    t.string   "test_suite_version"
    t.jsonb    "versions"
    t.datetime "event_created_at"
  end

end
