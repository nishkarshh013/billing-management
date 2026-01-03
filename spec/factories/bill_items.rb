# spec/factories/bill_items.rb
FactoryBot.define do
  factory :bill_item do
    association :bill
    association :product
    quantity { 1 }
    unit_price { 100.0 }
    tax_percentage { 10.0 }
    tax_amount { 10.0 }
    total_price { 100.0 }
  end
end