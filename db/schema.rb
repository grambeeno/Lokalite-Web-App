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

ActiveRecord::Schema.define(:version => 20111107030101) do

  create_table "event_images", :force => true do |t|
    t.string   "image"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "repeating"
    t.integer  "prototype_id"
    t.integer  "organization_id"
    t.integer  "image_id"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "clone_count",           :default => 0
    t.integer  "users_count",           :default => 0
    t.decimal  "trend_weight",          :default => 0.0
    t.integer  "anonymous_trend_count", :default => 0
  end

  add_index "events", ["description"], :name => "index_events_on_description"
  add_index "events", ["ends_at"], :name => "index_events_on_ends_at"
  add_index "events", ["image_id"], :name => "index_events_on_image_id"
  add_index "events", ["location_id"], :name => "index_events_on_location_id"
  add_index "events", ["name"], :name => "index_events_on_name"
  add_index "events", ["organization_id"], :name => "index_events_on_organization_id"
  add_index "events", ["prototype_id"], :name => "index_events_on_event_id"
  add_index "events", ["repeating"], :name => "index_events_on_repeating"
  add_index "events", ["starts_at"], :name => "index_events_on_starts_at"

  create_table "geocodes", :force => true do |t|
    t.decimal "latitude",    :precision => 15, :scale => 12
    t.decimal "longitude",   :precision => 15, :scale => 12
    t.string  "query"
    t.string  "street"
    t.string  "locality"
    t.string  "region"
    t.string  "postal_code"
    t.string  "country"
    t.string  "precision"
  end

  add_index "geocodes", ["country"], :name => "geocodes_country_index"
  add_index "geocodes", ["latitude"], :name => "geocodes_latitude_index"
  add_index "geocodes", ["locality"], :name => "geocodes_locality_index"
  add_index "geocodes", ["longitude"], :name => "geocodes_longitude_index"
  add_index "geocodes", ["postal_code"], :name => "geocodes_postal_code_index"
  add_index "geocodes", ["precision"], :name => "geocodes_precision_index"
  add_index "geocodes", ["query"], :name => "geocodes_query_index", :unique => true
  add_index "geocodes", ["region"], :name => "geocodes_region_index"

  create_table "geocodings", :force => true do |t|
    t.integer "geocodable_id"
    t.integer "geocode_id"
    t.string  "geocodable_type"
  end

  add_index "geocodings", ["geocodable_id"], :name => "geocodings_geocodable_id_index"
  add_index "geocodings", ["geocodable_type"], :name => "geocodings_geocodable_type_index"
  add_index "geocodings", ["geocode_id"], :name => "geocodings_geocode_id_index"

  create_table "locations", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "geocoded_street"
    t.string   "locality"
    t.string   "region"
    t.string   "postal_code"
    t.string   "country"
    t.integer  "organization_id"
    t.float    "utc_offset"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "suite"
    t.string   "user_given_street"
  end

  add_index "locations", ["locality"], :name => "index_locations_on_locality"
  add_index "locations", ["name"], :name => "index_locations_on_name"
  add_index "locations", ["postal_code"], :name => "index_locations_on_postal_code"
  add_index "locations", ["uuid"], :name => "index_locations_on_uuid", :unique => true

  create_table "organizations", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.text     "description"
    t.string   "email"
    t.string   "url"
    t.string   "phone"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["name"], :name => "index_organizations_on_name"
  add_index "organizations", ["uuid"], :name => "index_organizations_on_uuid", :unique => true

  create_table "plan_user_invitations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.boolean  "accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "request_id"
    t.string   "uuid"
  end

  add_index "plan_user_invitations", ["accepted"], :name => "index_plan_user_invitations_on_accepted"
  add_index "plan_user_invitations", ["plan_id"], :name => "index_plan_user_invitations_on_plan_id"
  add_index "plan_user_invitations", ["user_id"], :name => "index_plan_user_invitations_on_user_id"

  create_table "plans", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid"
    t.string   "title"
    t.boolean  "public",      :default => false
    t.text     "description"
    t.text     "event_list"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plans", ["user_id"], :name => "index_plans_on_user_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "sessions", :force => true do |t|
    t.text     "data",       :default => "--- {}\n\n"
    t.integer  "user_id",                              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["user_id"], :name => "index_sessions_on_user_id", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_event_joins", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_organization_joins", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_organization_joins", ["organization_id"], :name => "index_user_organization_joins_on_organization_id"
  add_index "user_organization_joins", ["user_id"], :name => "index_user_organization_joins_on_user_id"

  create_table "user_role_joins", :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.boolean  "primary",    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_role_joins", ["primary"], :name => "index_user_role_joins_on_primary"
  add_index "user_role_joins", ["role_id"], :name => "index_user_role_joins_on_role_id"
  add_index "user_role_joins", ["user_id"], :name => "index_user_role_joins_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "uuid",                                                                             :null => false
    t.string   "email"
    t.string   "encrypted_password",     :limit => 128, :default => "",                            :null => false
    t.string   "time_zone",                             :default => "Mountain Time (US & Canada)"
    t.string   "handle"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.text     "facebook_data"
    t.text     "settings"
  end

  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["encrypted_password"], :name => "index_users_on_password"
  add_index "users", ["handle"], :name => "index_users_on_handle"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["updated_at"], :name => "index_users_on_updated_at"
  add_index "users", ["uuid"], :name => "index_users_on_uuid", :unique => true

end
