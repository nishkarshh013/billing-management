class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name, index: true
      t.string :email, index: { unique: true }, null: false

      t.timestamps
    end
  end
end
