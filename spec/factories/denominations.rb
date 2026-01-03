# spec/factories/denominations.rb
FactoryBot.define do
  factory :denomination do
    value { 100 }
    quantity { 10 }
  end
end