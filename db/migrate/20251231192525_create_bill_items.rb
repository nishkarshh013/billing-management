class CreateBillItems < ActiveRecord::Migration[8.1]
  def change
    create_table :bill_items do |t|
      t.references :bill, null: false, foreign_key: true, index: true
      t.references :product, null: false, foreign_key: true, index: true
      t.integer :quantity, null: false
      t.decimal :unit_price, null: false, precision: 10, scale: 2
      t.decimal :tax_percentage, null: false, precision: 10, scale: 2
      t.decimal :tax_amount, null: false, precision: 10, scale: 2
      t.decimal :total_price, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
