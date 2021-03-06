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

ActiveRecord::Schema.define(version: 20160618182944) do

  create_table "action_smser_delivery_reports", force: true do |t|
    t.string   "msg_id"
    t.string   "status"
    t.datetime "status_updated_at"
    t.string   "sms_type"
    t.text     "log"
    t.string   "to"
    t.string   "from"
    t.text     "body",                              limit: 255
    t.string   "gateway"
    t.integer  "re_delivery_of_delivery_report_id"
    t.boolean  "re_delivered"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "pluie_id"
  end

  add_index "action_smser_delivery_reports", ["msg_id"], name: "index_action_smser_delivery_reports_on_msg_id"
  add_index "action_smser_delivery_reports", ["pluie_id"], name: "index_action_smser_delivery_reports_on_pluie_id"
  add_index "action_smser_delivery_reports", ["user_id"], name: "index_action_smser_delivery_reports_on_user_id"

  create_table "api_settings", force: true do |t|
    t.string   "api_key"
    t.string   "api_secret"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bills", force: true do |t|
    t.integer  "number_of_sms"
    t.string   "message_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "finished_sms",           default: 0
    t.integer  "accepted_numbers",       default: 0
    t.float    "price_numbers_accepted", default: 0.0
  end

  add_index "bills", ["message_id"], name: "index_bills_on_message_id"
  add_index "bills", ["user_id"], name: "index_bills_on_user_id"

  create_table "bulk_messages", force: true do |t|
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "route_id"
    t.string   "url_callback"
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
    t.integer  "gsm_number_id"
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
    t.string   "description"
  end

  create_table "debits", force: true do |t|
    t.integer  "user_id"
    t.decimal  "balance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "debits", ["user_id"], name: "index_debits_on_user_id"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "gateway_prefixtables", force: true do |t|
    t.integer  "gateway_id"
    t.integer  "prefix_table_id"
    t.float    "price_system"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price_cost"
  end

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
    t.boolean  "opened",            default: true
  end

  create_table "observers", force: true do |t|
    t.string   "number"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gsm_number_id"
  end

  add_index "observers", ["gsm_number_id"], name: "index_observers_on_gsm_number_id"

  create_table "permission_ressls", force: true do |t|
    t.string   "name_class"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permission_ressls_users", id: false, force: true do |t|
    t.integer "permission_ressl_id"
    t.integer "user_id"
  end

  create_table "prefix_tables", force: true do |t|
    t.string   "country_code"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "routes", force: true do |t|
    t.decimal  "price"
    t.integer  "user_id"
    t.integer  "gateway_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "system_route",    default: false
    t.integer  "create_route_id", default: 0
  end

  create_table "routes_users", id: false, force: true do |t|
    t.integer "route_id"
    t.integer "user_id"
  end

  create_table "single_messages", force: true do |t|
    t.text     "message"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "route_id"
    t.string   "url_callback"
  end

  create_table "table_routes", force: true do |t|
    t.string   "name_route"
    t.float    "price_system"
    t.float    "price_cost"
    t.string   "country_code"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "route_id",     default: 1
  end

  create_table "topups", force: true do |t|
    t.string   "number"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.decimal  "credit",                 default: 0.0
    t.decimal  "debit",                  default: 0.0
    t.string   "locale",                 default: "es"
    t.string   "url_callback"
    t.string   "movil_number"
    t.string   "token_number"
    t.datetime "confirm_token_number"
    t.string   "low_account"
    t.boolean  "unit_view"
    t.boolean  "unit_views",             default: false
    t.integer  "nested_reseller",        default: 0
    t.boolean  "reseller",               default: false
    t.integer  "belongs_resll",          default: 0
    t.integer  "route_default",          default: 0
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
