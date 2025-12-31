class CreateBills < ActiveRecord::Migration[8.1]
  def change
    create_table :bills do |t|
      t.references :customer, null: false, foreign_key: true, index: true
      t.decimal :total_without_tax, precision: 10, scale: 2, null: false
      t.decimal :total_tax, precision: 10, scale: 2, null: false
      t.decimal :net_amount, precision: 10, scale: 2, null: false
      t.decimal :rounded_amount, precision: 10, scale: 2
      t.decimal :paid_amount, precision: 10, scale: 2, null: false
      t.decimal :balance_amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
