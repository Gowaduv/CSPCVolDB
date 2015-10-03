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

ActiveRecord::Schema.define(version: 20150920094924) do

  create_table "calendars", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.string   "name"
    t.string   "abbv"
    t.time     "open_time"
    t.integer  "duration"
    t.integer  "default_location"
    t.integer  "calendar_id"
    t.text     "schedule_yaml"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offers", force: true do |t|
    t.integer  "user_id"
    t.integer  "schedule_id"
    t.integer  "accepted"
    t.datetime "accepted_timestamp"
    t.integer  "accepted_user_id"
    t.integer  "denied"
    t.datetime "denied_timestamp"
    t.integer  "denied_user_id"
    t.integer  "revoked"
    t.datetime "revoke_timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "offers", ["schedule_id"], name: "index_offers_on_schedule_id", using: :btree
  add_index "offers", ["user_id"], name: "index_offers_on_user_id", using: :btree

  create_table "positions", force: true do |t|
    t.string   "name"
    t.integer  "training",   default: 0
    t.integer  "shadowing",  default: 3
    t.text     "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "qualifications", force: true do |t|
    t.integer  "user_id"
    t.integer  "position_id"
    t.string   "status"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "qualifications", ["position_id"], name: "index_qualifications_on_position_id", using: :btree
  add_index "qualifications", ["user_id"], name: "index_qualifications_on_user_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.string   "desc"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "schedules", force: true do |t|
    t.integer  "staff_id"
    t.integer  "offer_id"
    t.integer  "location_id"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedules", ["location_id"], name: "index_schedules_on_location_id", using: :btree
  add_index "schedules", ["offer_id"], name: "index_schedules_on_offer_id", using: :btree
  add_index "schedules", ["staff_id"], name: "index_schedules_on_staff_id", using: :btree

  create_table "shifts", force: true do |t|
    t.string   "start"
    t.string   "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staffs", force: true do |t|
    t.integer  "event_id"
    t.integer  "position_id"
    t.integer  "shift_id"
    t.integer  "permanent_user"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "staffs", ["event_id"], name: "index_staffs_on_event_id", using: :btree
  add_index "staffs", ["position_id"], name: "index_staffs_on_position_id", using: :btree
  add_index "staffs", ["shift_id"], name: "index_staffs_on_shift_id", using: :btree

  create_table "users", force: true do |t|
    t.integer  "member_number",                       null: false
    t.string   "username",                            null: false
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["member_number"], name: "index_users_on_member_number", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "users_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.integer  "event_id"
    t.integer  "added_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users_roles", ["user_id", "role_id", "event_id"], name: "index_users_roles_on_user_id_and_role_id_and_event_id", using: :btree
  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
