class Bill < ApplicationRecord
  belongs_to :customer

  has_many :bill_items, dependent: :destroy
  has_many :bill_denominations, dependent: :destroy

  validates :total_without_tax, :total_tax, :net_amount,
              :rounded_amount, :paid_amount, :balance_amount, presence: true

  validates :paid_amount, numericality: { greater_than_or_equal_to: 0 }
end
