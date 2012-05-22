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

ActiveRecord::Schema.define(:version => 20120522081453) do

  create_table "photos", :force => true do |t|
    t.datetime "shot_at"
    t.decimal  "lat"
    t.decimal  "lng"
    t.integer  "user_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "share_hash"
    t.string   "location"
    t.string   "md5"
  end

  add_index "photos", ["share_hash"], :name => "index_photos_on_share_hash"
  add_index "photos", ["shot_at"], :name => "index_photos_on_shot_at"

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
