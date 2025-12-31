class BillItem < ApplicationRecord
  belongs_to :bill_id
  belongs_to :product_id
end
