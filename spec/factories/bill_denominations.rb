# spec/factories/bill_denominations.rb
FactoryBot.define do
  factory :bill_denomination do
    association :bill
    association :denomination
    count { 1 }
  end
end