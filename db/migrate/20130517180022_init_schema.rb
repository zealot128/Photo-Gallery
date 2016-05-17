class InitSchema < ActiveRecord::Migration
  def up

    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"

    create_table "days", force: :cascade do |t|
      t.date     "date"
      t.integer  "year"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "montage_file_name"
      t.string   "montage_content_type"
      t.integer  "montage_file_size"
      t.datetime "montage_updated_at"
      t.string   "locations"
      t.index ["date"], name: "index_days_on_date", using: :btree
    end

    create_table "photos", force: :cascade do |t|
      t.datetime "shot_at"
      t.decimal  "lat"
      t.decimal  "lng"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "file_file_name"
      t.string   "file_content_type"
      t.integer  "file_file_size"
      t.datetime "file_updated_at"
      t.string   "share_hash"
      t.string   "location"
      t.string   "md5"
      t.integer  "year",              limit: 2
      t.integer  "month",             limit: 2
      t.integer  "day_id"
      t.text     "exif_info"
      t.string   "caption"
      t.text     "description"
      t.index ["day_id"], name: "index_photos_on_day_id", using: :btree
      t.index ["md5"], name: "index_photos_on_md5", unique: true, using: :btree
      t.index ["month"], name: "index_photos_on_month", using: :btree
      t.index ["share_hash"], name: "index_photos_on_share_hash", using: :btree
      t.index ["shot_at"], name: "index_photos_on_shot_at", using: :btree
      t.index ["year"], name: "index_photos_on_year", using: :btree
    end

    create_table "photos_shares", id: false, force: :cascade do |t|
      t.integer "share_id"
      t.integer "photo_id"
      t.index ["share_id", "photo_id"], name: "index_photos_shares_on_share_id_and_photo_id", unique: true, using: :btree
    end

    create_table "shares", force: :cascade do |t|
      t.string   "name"
      t.string   "type"
      t.string   "token"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["token"], name: "index_shares_on_token", unique: true, using: :btree
      t.index ["type"], name: "index_shares_on_type", using: :btree
    end

    create_table "taggings", force: :cascade do |t|
      t.integer  "tag_id"
      t.string   "taggable_type"
      t.integer  "taggable_id"
      t.string   "tagger_type"
      t.integer  "tagger_id"
      t.string   "context",       limit: 128
      t.datetime "created_at"
      t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
      t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
    end

    create_table "tags", force: :cascade do |t|
      t.string "name"
    end

    create_table "users", force: :cascade do |t|
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

  def down
    raise "Can not revert initial migration"
  end
end
