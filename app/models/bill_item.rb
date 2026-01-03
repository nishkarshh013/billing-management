class BillItem < ApplicationRecord
  belongs_to :bill
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, :tax_percentage,
              :tax_amount, :total_price, presence: true
end
