class CreateDenominations < ActiveRecord::Migration[8.1]
  def change
    create_table :denominations do |t|
      t.integer :value, null: false, index: {unique: true}

      t.timestamps
    end
  end
end
