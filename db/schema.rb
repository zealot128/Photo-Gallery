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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130106200657) do

  create_table "days", :force => true do |t|
    t.date     "date"
    t.integer  "year"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "montage_file_name"
    t.string   "montage_content_type"
    t.integer  "montage_file_size"
    t.datetime "montage_updated_at"
    t.string   "locations"
  end

  add_index "days", ["date"], :name => "index_days_on_date"

  create_table "photos", :force => true do |t|
    t.datetime "shot_at"
    t.decimal  "lat"
    t.decimal  "lng"
    t.integer  "user_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "share_hash"
    t.string   "location"
    t.string   "md5"
    t.integer  "year",              :limit => 2
    t.integer  "month",             :limit => 2
    t.integer  "day_id"
    t.text     "exif_info"
    t.string   "caption"
  end

  add_index "photos", ["day_id"], :name => "index_photos_on_day_id"
  add_index "photos", ["md5"], :name => "index_photos_on_md5", :unique => true
  add_index "photos", ["month"], :name => "index_photos_on_month"
  add_index "photos", ["share_hash"], :name => "index_photos_on_share_hash"
  add_index "photos", ["shot_at"], :name => "index_photos_on_shot_at"
  add_index "photos", ["year"], :name => "index_photos_on_year"

  create_table "photos_shares", :id => false, :force => true do |t|
    t.integer "share_id"
    t.integer "photo_id"
  end

  add_index "photos_shares", ["share_id", "photo_id"], :name => "index_photos_shares_on_share_id_and_photo_id", :unique => true

  create_table "shares", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "shares", ["token"], :name => "index_shares_on_token", :unique => true
  add_index "shares", ["type"], :name => "index_shares_on_type"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "last_ip"
    t.datetime "last_upload"
    t.boolean  "allowed_ip_storing"
  end

end
