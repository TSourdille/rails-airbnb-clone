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

ActiveRecord::Schema.define(version: 20161116101154) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachinary_files", force: :cascade do |t|
    t.string   "attachinariable_type"
    t.integer  "attachinariable_id"
    t.string   "scope"
    t.string   "public_id"
    t.string   "version"
    t.integer  "width"
    t.integer  "height"
    t.string   "format"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["attachinariable_type", "attachinariable_id", "scope"], name: "by_scoped_parent", using: :btree
  end

  create_table "availabilities", force: :cascade do |t|
    t.date     "start_at"
    t.date     "end_at"
    t.integer  "boat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["boat_id"], name: "index_availabilities_on_boat_id", using: :btree
  end

  create_table "boats", force: :cascade do |t|
    t.string   "boat_type"
    t.string   "name"
    t.string   "city"
    t.string   "capacity"
    t.text     "description"
    t.text     "specs"
    t.text     "equipment"
    t.integer  "day_rate"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "length"
    t.string   "beds"
    t.string   "image1"
    t.string   "image2"
    t.string   "image3"
    t.index ["user_id"], name: "index_boats_on_user_id", using: :btree
  end

  create_table "bookings", force: :cascade do |t|
    t.integer  "boat_id"
    t.integer  "user_id"
    t.date     "start_at"
    t.date     "end_at"
    t.text     "user_review"
    t.text     "owner_review"
    t.integer  "user_rating"
    t.integer  "owner_rating"
    t.date     "validated_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["boat_id"], name: "index_bookings_on_boat_id", using: :btree
    t.index ["user_id"], name: "index_bookings_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.boolean  "boat_license",           default: false
    t.string   "provider"
    t.string   "uid"
    t.string   "facebook_picture_url"
    t.string   "token"
    t.datetime "token_expiry"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "availabilities", "boats"
  add_foreign_key "boats", "users"
  add_foreign_key "bookings", "boats"
  add_foreign_key "bookings", "users"
end
