# spec/factories/bills.rb
FactoryBot.define do
  factory :bill do
    association :customer
    total_without_tax { 100.0 }
    total_tax { 10.0 }
    net_amount { 110.0 }
    rounded_amount { 110.0 }
    paid_amount { 150.0 }
    balance_amount { 40.0 }
  end
end
