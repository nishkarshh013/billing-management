class AddQuantityToDenominations < ActiveRecord::Migration[8.1]
  def change
    add_column :denominations, :quantity, :integer, null: false
  end
end
