# spec/factories/products.rb
FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:product_code) { |n| "P#{n.to_s.rjust(3, '0')}" }
    price { 100.0 }
    tax_percentage { 10.0 }
    stock { 50 }
  end
end
