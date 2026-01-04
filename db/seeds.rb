# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding products..."

products = [
  { name: "Laptop", product_code: "P001", price: 50000, tax_percentage: 18, stock: 10 },
  { name: "Mouse", product_code: "P002", price: 500, tax_percentage: 12, stock: 50 },
  { name: "Keyboard", product_code: "P003", price: 1500, tax_percentage: 12, stock: 30 }
]

products.each do |product|
  Product.find_or_create_by!(product_code: product[:product_code]) do |p|
    p.name = product[:name]
    p.price = product[:price]
    p.tax_percentage = product[:tax_percentage]
    p.stock = product[:stock]
  end
end

puts "Products seeded"

puts "Seeding denominations..."

[
  { value: 500, quantity: 10 },
  { value: 100, quantity: 20 },
  { value: 50,  quantity: 30 },
  { value: 20,  quantity: 50 },
  { value: 10,  quantity: 50 }

].each do |d|
  Denomination.create!(d)
end

puts "Denominations seeded"
