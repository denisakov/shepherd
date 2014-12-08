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

ActiveRecord::Schema.define(version: 20141203160009) do

  create_table "owners", force: true do |t|
    t.string   "name"
    t.string   "rus_name"
    t.text     "contact"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "given_name"
  end

  create_table "positions", force: true do |t|
    t.float    "long",       limit: 24
    t.float    "lat",        limit: 24
    t.string   "dest"
    t.string   "prev_dest"
    t.string   "last_port"
    t.date     "eta"
    t.datetime "eta_time"
    t.string   "nav_status"
    t.date     "last_upt"
    t.integer  "vessel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "now_near"
  end

  add_index "positions", ["vessel_id"], name: "index_positions_on_vessel_id", using: :btree

  create_table "shipment_statuses", force: true do |t|
    t.string   "title"
    t.integer  "shipment_id"
    t.string   "status"
    t.string   "next_status"
    t.date     "next_comp_date"
    t.datetime "next_comp_time"
    t.datetime "comp_date"
    t.datetime "comp_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  add_index "shipment_statuses", ["shipment_id"], name: "index_shipment_statuses_on_shipment_id", using: :btree

  create_table "shipments", force: true do |t|
    t.string   "title"
    t.integer  "vessel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipments", ["vessel_id"], name: "index_shipments_on_vessel_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vessels", force: true do |t|
    t.string   "vsl_name"
    t.string   "vsl_type"
    t.date     "blt_year"
    t.string   "vsl_flag"
    t.string   "imo"
    t.string   "mmsi"
    t.string   "vsl_proj"
    t.string   "vsl_dwt"
    t.integer  "vsl_dwcc"
    t.integer  "vsl_gt"
    t.integer  "vsl_nt"
    t.integer  "vsl_l"
    t.integer  "vsl_w"
    t.integer  "vsl_depth"
    t.integer  "vsl_draft"
    t.integer  "vsl_cbm"
    t.integer  "h1_l"
    t.integer  "h1_w"
    t.integer  "h1_h"
    t.integer  "h2_l"
    t.integer  "h2_w"
    t.integer  "h2_h"
    t.integer  "h3_l"
    t.integer  "h3_w"
    t.integer  "h3_h"
    t.integer  "h4_l"
    t.integer  "h4_w"
    t.integer  "h4_h"
    t.integer  "h5_l"
    t.integer  "h5_w"
    t.integer  "h5_h"
    t.integer  "h6_l"
    t.integer  "h6_w"
    t.integer  "h6_h"
    t.integer  "ha1_l"
    t.integer  "ha1_w"
    t.integer  "ha1_h"
    t.integer  "ha2_l"
    t.integer  "ha2_w"
    t.integer  "ha2_h"
    t.integer  "ha3_l"
    t.integer  "ha3_w"
    t.integer  "ha3_h"
    t.integer  "ha4_l"
    t.integer  "ha4_w"
    t.integer  "ha4_h"
    t.integer  "h_safeload"
    t.integer  "ha_safeload"
    t.string   "vsl_note"
    t.string   "vsl_link"
    t.string   "vsl_cargotype"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  add_index "vessels", ["owner_id"], name: "index_vessels_on_owner_id", using: :btree

end
