class BillDenomination < ApplicationRecord
  belongs_to :bill
  belongs_to :denomination

  validates :count, numericality: { greater_than_or_equal_to: 0 }
end
