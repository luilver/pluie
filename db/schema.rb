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

ActiveRecord::Schema.define(version: 20140725233202) do

  create_table "api_settings", force: true do |t|
    t.string   "api_key"
    t.string   "api_secret"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bulk_messages", force: true do |t|
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "bulk_messages_gsm_numbers", id: false, force: true do |t|
    t.integer "bulk_message_id"
    t.integer "gsm_number_id"
  end

  create_table "bulk_messages_lists", force: true do |t|
    t.integer "bulk_message_id"
    t.integer "list_id"
  end

  create_table "contacts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "contacts_groups", id: false, force: true do |t|
    t.integer "group_id"
    t.integer "contact_id"
  end

  create_table "contacts_gsm_numbers", id: false, force: true do |t|
    t.integer "contact_id"
    t.integer "gsm_number_id"
  end

  create_table "credits", force: true do |t|
    t.decimal  "balance"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "delivery_reports", force: true do |t|
    t.string   "msg_id"
    t.string   "status"
    t.datetime "status_updated_at"
    t.string   "sms_type"
    t.text     "log"
    t.string   "to"
    t.string   "from"
    t.string   "body"
    t.string   "gateway"
    t.integer  "re_delivery_of_delivery_report_id"
    t.boolean  "re_delivered"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "delivery_reports", ["msg_id"], name: "index_delivery_reports_on_msg_id"

  create_table "gateways", force: true do |t|
    t.string   "name"
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_messages", force: true do |t|
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "group_messages_groups", id: false, force: true do |t|
    t.integer "group_message_id"
    t.integer "group_id"
  end

  create_table "groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "gsm_numbers", force: true do |t|
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gsm_numbers_lists", id: false, force: true do |t|
    t.integer "list_id"
    t.integer "gsm_number_id"
  end

  create_table "gsm_numbers_single_messages", id: false, force: true do |t|
    t.integer "single_message_id"
    t.integer "gsm_number_id"
  end

  create_table "lists", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  create_table "single_messages", force: true do |t|
    t.text     "message"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "sms", force: true do |t|
    t.integer  "gateway_id"
    t.integer  "user_id"
    t.integer  "msg_id"
    t.string   "msg_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "receiver"
  end

  add_index "sms", ["gateway_id"], name: "index_sms_on_gateway_id"
  add_index "sms", ["msg_id", "msg_type"], name: "index_sms_on_msg_id_and_msg_type"
  add_index "sms", ["user_id"], name: "index_sms_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",  null: false
    t.string   "encrypted_password",     default: "",  null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
    t.decimal  "balance",                default: 0.0
    t.integer  "gateway_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
