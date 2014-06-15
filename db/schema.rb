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

ActiveRecord::Schema.define(version: 20140615233904) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "days", force: true do |t|
    t.date     "date"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locations"
    t.string   "montage"
  end

  add_index "days", ["date"], name: "index_days_on_date", using: :btree

  create_table "photos", force: true do |t|
    t.datetime "shot_at"
    t.float    "lat"
    t.float    "lng"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "share_hash"
    t.string   "location"
    t.string   "md5"
    t.integer  "year",        limit: 2
    t.integer  "month",       limit: 2
    t.integer  "day_id"
    t.text     "exif_info"
    t.string   "caption"
    t.text     "description"
    t.string   "file"
    t.json     "meta_data"
  end

  add_index "photos", ["day_id"], name: "index_photos_on_day_id", using: :btree
  add_index "photos", ["md5"], name: "index_photos_on_md5", unique: true, using: :btree
  add_index "photos", ["month"], name: "index_photos_on_month", using: :btree
  add_index "photos", ["share_hash"], name: "index_photos_on_share_hash", using: :btree
  add_index "photos", ["shot_at"], name: "index_photos_on_shot_at", using: :btree
  add_index "photos", ["year"], name: "index_photos_on_year", using: :btree

  create_table "photos_shares", id: false, force: true do |t|
    t.integer "share_id"
    t.integer "photo_id"
  end

  add_index "photos_shares", ["share_id", "photo_id"], name: "index_photos_shares_on_share_id_and_photo_id", unique: true, using: :btree

  create_table "shares", force: true do |t|
    t.string   "name"
    t.string   "type"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shares", ["token"], name: "index_shares_on_token", unique: true, using: :btree
  add_index "shares", ["type"], name: "index_shares_on_type", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_ip"
    t.datetime "last_upload"
    t.boolean  "allowed_ip_storing"
  end

end
