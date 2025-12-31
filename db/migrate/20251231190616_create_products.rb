class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, index: true, null: false
      t.string :product_code, index: {unique: true}, null: false
      t.integer :stock, null: false
      t.decimal :price, precision: 10, scale: 2 ,null: false
      t.decimal :tax_percentage, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
