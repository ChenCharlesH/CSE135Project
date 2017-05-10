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

ActiveRecord::Schema.define(version: 20170503232028) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "product_id", null: false
    t.integer  "quantity",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_carts_on_product_id", using: :btree
    t.index ["user_id"], name: "index_carts_on_user_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string   "unique_name",              null: false
    t.integer  "user_id",                  null: false
    t.string   "desc",        limit: 1023
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["unique_name"], name: "index_categories_on_unique_name", unique: true, using: :btree
    t.index ["user_id"], name: "index_categories_on_user_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.integer  "category_id",             null: false
    t.string   "unique_name",             null: false
    t.string   "sku",                     null: false
    t.integer  "price",       default: 0, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["category_id"], name: "index_products_on_category_id", using: :btree
    t.index ["unique_name"], name: "index_products_on_unique_name", unique: true, using: :btree
  end

  create_table "purchases", force: :cascade do |t|
    t.integer  "user_id",                                    null: false
    t.integer  "product_id",                                 null: false
    t.integer  "quantity",                                   null: false
    t.datetime "time",       default: '2017-05-04 22:57:04', null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.index ["product_id"], name: "index_purchases_on_product_id", using: :btree
    t.index ["user_id"], name: "index_purchases_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "unique_name",        default: "",    null: false
    t.string   "encrypted_password", default: "",    null: false
    t.boolean  "owner",              default: false
    t.integer  "age",                default: 0,     null: false
    t.string   "state",              default: "CA",  null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["unique_name"], name: "index_users_on_unique_name", unique: true, using: :btree
  end

  add_foreign_key "carts", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "products", "categories"
  add_foreign_key "purchases", "products"
  add_foreign_key "purchases", "users"
end
