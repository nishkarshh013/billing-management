class Denomination < ApplicationRecord
  has_many :bill_denominations, dependent: :destroy

  validates :value, presence: true, numericality: { greater_than: 0 }
end
