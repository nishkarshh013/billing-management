class Product < ApplicationRecord
  has_many :bill_items

  validates :name, :product_code, presence: true
  validates :product_code, uniqueness: true
  validates :stock, :tax_percentage, numericality: { greater_than_or_equal_to: 0 }
  validates :price, numericality: { greater_than: 0 }
end
