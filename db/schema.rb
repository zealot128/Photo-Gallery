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

ActiveRecord::Schema.define(version: 20161228175709) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "base_files_image_labels", id: false, force: :cascade do |t|
    t.integer "base_file_id"
    t.integer "image_label_id"
    t.index ["base_file_id", "image_label_id"], name: "base_files_image_labels_index", unique: true, using: :btree
  end

  create_table "days", force: :cascade do |t|
    t.date     "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "locations"
    t.string   "montage"
    t.integer  "month_id"
    t.index ["date"], name: "index_days_on_date", using: :btree
    t.index ["month_id"], name: "index_days_on_month_id", using: :btree
  end

  create_table "image_faces", force: :cascade do |t|
    t.json     "bounding_box"
    t.string   "file"
    t.integer  "base_file_id"
    t.integer  "person_id"
    t.uuid     "aws_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.float    "confidence"
    t.index ["base_file_id"], name: "index_image_faces_on_base_file_id", using: :btree
    t.index ["person_id"], name: "index_image_faces_on_person_id", using: :btree
  end

  create_table "image_labels", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "months", force: :cascade do |t|
    t.integer  "month_number"
    t.integer  "year_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "month_string"
    t.index ["year_id"], name: "index_months_on_year_id", using: :btree
  end

  create_table "people", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "photos", force: :cascade do |t|
    t.datetime "shot_at"
    t.float    "lat"
    t.float    "lng"
    t.integer  "user_id"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.string   "location"
    t.string   "md5"
    t.integer  "year"
    t.integer  "month"
    t.integer  "day_id"
    t.string   "caption"
    t.text     "description"
    t.string   "file"
    t.json     "meta_data"
    t.string   "type"
    t.bigint   "file_size"
    t.boolean  "rekognition_labels_run",                         default: false
    t.boolean  "rekognition_faces_run",                          default: false
    t.decimal  "aperture",               precision: 5, scale: 2
    t.index ["aperture"], name: "index_photos_on_aperture", using: :btree
    t.index ["day_id"], name: "index_photos_on_day_id", using: :btree
    t.index ["file_size"], name: "index_photos_on_file_size", using: :btree
    t.index ["md5"], name: "index_photos_on_md5", unique: true, using: :btree
    t.index ["month"], name: "index_photos_on_month", using: :btree
    t.index ["shot_at"], name: "index_photos_on_shot_at", using: :btree
    t.index ["type"], name: "index_photos_on_type", using: :btree
    t.index ["year"], name: "index_photos_on_year", using: :btree
  end

  create_table "photos_shares", id: false, force: :cascade do |t|
    t.integer "share_id"
    t.integer "photo_id"
    t.index ["share_id", "photo_id"], name: "index_photos_shares_on_share_id_and_photo_id", unique: true, using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree
  end

  create_table "shares", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.index ["token"], name: "index_shares_on_token", unique: true, using: :btree
    t.index ["type"], name: "index_shares_on_type", using: :btree
  end

  create_table "similarities", force: :cascade do |t|
    t.integer "image_face1_id"
    t.integer "image_face2_id"
    t.float   "similarity"
    t.bigint  "created_at"
    t.index ["image_face2_id", "image_face1_id"], name: "index_similarities_on_image_face2_id_and_image_face1_id", unique: true, using: :btree
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context", using: :btree
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "upload_logs", force: :cascade do |t|
    t.string   "file_name"
    t.bigint   "file_size"
    t.integer  "status",       default: 0
    t.integer  "user_id"
    t.text     "message"
    t.string   "ip"
    t.text     "user_agent"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "base_file_id"
    t.index ["user_id"], name: "index_upload_logs_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "last_ip"
    t.datetime "last_upload"
    t.boolean  "allowed_ip_storing"
    t.string   "token"
    t.string   "pseudo_password"
    t.boolean  "admin"
    t.string   "timezone"
    t.string   "locale"
  end

  create_table "years", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "upload_logs", "users"
end
