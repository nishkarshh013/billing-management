# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_31_192832) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bill_denominations", force: :cascade do |t|
    t.bigint "bill_id", null: false
    t.integer "count", null: false
    t.datetime "created_at", null: false
    t.bigint "denomination_id", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_bill_denominations_on_bill_id"
    t.index ["denomination_id"], name: "index_bill_denominations_on_denomination_id"
  end

  create_table "bill_items", force: :cascade do |t|
    t.bigint "bill_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "tax_amount", precision: 10, scale: 2, null: false
    t.decimal "tax_percentage", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_bill_items_on_bill_id"
    t.index ["product_id"], name: "index_bill_items_on_product_id"
  end

  create_table "bills", force: :cascade do |t|
    t.decimal "balance_amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.decimal "net_amount", precision: 10, scale: 2, null: false
    t.decimal "paid_amount", precision: 10, scale: 2, null: false
    t.decimal "rounded_amount", precision: 10, scale: 2
    t.decimal "total_tax", precision: 10, scale: 2, null: false
    t.decimal "total_without_tax", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_bills_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email", unique: true
    t.index ["name"], name: "index_customers_on_name"
  end

  create_table "denominations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "value", null: false
    t.index ["value"], name: "index_denominations_on_value", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "product_code", null: false
    t.integer "stock", null: false
    t.decimal "tax_percentage", precision: 8, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_products_on_name"
    t.index ["product_code"], name: "index_products_on_product_code", unique: true
  end

  add_foreign_key "bill_denominations", "bills"
  add_foreign_key "bill_denominations", "denominations"
  add_foreign_key "bill_items", "bills"
  add_foreign_key "bill_items", "products"
  add_foreign_key "bills", "customers"
end
