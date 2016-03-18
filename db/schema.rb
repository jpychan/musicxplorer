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

ActiveRecord::Schema.define(version: 20160317195857) do

  create_table "festival_genres", force: :cascade do |t|
    t.integer  "festival_id"
    t.integer  "genre_1_id"
    t.integer  "genre_2_id"
    t.integer  "genre_3_id"
    t.integer  "genre_4_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "festivals", force: :cascade do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "location"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "website"
    t.text     "description"
    t.string   "artist_lineup"
    t.integer  "price"
    t.string   "currency"
    t.boolean  "camping"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "genres", force: :cascade do |t|
    t.string   "genre_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
