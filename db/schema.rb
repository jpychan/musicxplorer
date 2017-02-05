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

ActiveRecord::Schema.define(version: 20160326230122) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "airports", force: :cascade do |t|
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "city"
    t.string   "country"
    t.string   "iata_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artists", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "festival_genres", force: :cascade do |t|
    t.integer  "genre_id"
    t.integer  "festival_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "festival_genres", ["festival_id"], name: "index_festival_genres_on_festival_id", using: :btree
  add_index "festival_genres", ["genre_id"], name: "index_festival_genres_on_genre_id", using: :btree

  create_table "festivals", force: :cascade do |t|
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "date"
    t.string   "location"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "website"
    t.text     "description"
    t.integer  "price"
    t.string   "camping"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "festivals", ["camping"], name: "index_festivals_on_camping", using: :btree
  add_index "festivals", ["start_date"], name: "index_festivals_on_start_date", using: :btree

  create_table "genres", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "performances", force: :cascade do |t|
    t.integer  "festival_id"
    t.integer  "artist_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "performances", ["artist_id"], name: "index_performances_on_artist_id", using: :btree
  add_index "performances", ["festival_id"], name: "index_performances_on_festival_id", using: :btree

end
