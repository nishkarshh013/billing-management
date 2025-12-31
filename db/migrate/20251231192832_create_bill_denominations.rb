class CreateBillDenominations < ActiveRecord::Migration[8.1]
  def change
    create_table :bill_denominations do |t|
      t.references :bill, null: false, foreign_key: true, index: true
      t.references :denomination, null: false, foreign_key: true, index: true
      t.integer :count, null: false

      t.timestamps
    end
  end
end
