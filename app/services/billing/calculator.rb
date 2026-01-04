# app/services/billing/calculator.rb
class Billing::Calculator
  def initialize(input)
    @input = input
  end

  def call
    items = fetch_products
    stock_errors = validate_stock!(items)

    valid_items = items.reject do |item|
      stock_errors.any? { |e| e[:product_code] == item[:product].product_code }
    end

    total_without_tax, total_tax = calculate_totals(valid_items)
    net_amount = total_without_tax + total_tax

    if @input[:preview]
      return {
        success: stock_errors.empty?,
        stock_errors: stock_errors,
        total_without_tax: total_without_tax,
        total_tax: total_tax,
        net_amount: net_amount
      }
    end

    raise "Email is required" if @input[:email].blank?

    if stock_errors.any?
      raise stock_errors.map { |e|
        "#{e[:product_name]} has only #{e[:available]} left"
      }.join(", ")
    end

    raise "Insufficient payment" if paid_amount < net_amount

    change_amount = paid_amount - net_amount
    validate_customer_cash!
    change_result = calculate_change(change_amount)

    bill = persist!(
      valid_items,
      total_without_tax,
      total_tax,
      net_amount,
      change_amount,
      change_result[:denominations]
    )

    { success: true, bill: bill }
  rescue => e
    { success: false, error: e.message }
  end

  private

  def paid_amount
    @paid_amount ||= @input[:paid_amount].to_f
  end

  def fetch_products
    products = @input[:products]
    return [] if products.blank?

    products = products.values if products.is_a?(ActionController::Parameters)

    products.filter_map do |item|
      code = item[:product_code].presence
      qty  = item[:quantity].to_i

      next if code.blank? || qty <= 0

      {
        product: Product.find_by!(product_code: code),
        quantity: qty
      }
    end
  end


  def calculate_totals(items)
    total_without_tax = 0.0
    total_tax = 0.0

    items.each do |i|
      next if i[:quantity] < 1

      purchase_price = i[:product].price * i[:quantity]
      tax = purchase_price * i[:product].tax_percentage / 100.0

      total_without_tax += purchase_price
      total_tax += tax
    end

    [total_without_tax, total_tax]
  end

  def calculate_change(balance)
    balance_cents = (balance * 100).round
    denominations = {}

    Denomination.order(value: :desc).each do |d|
      break if balance_cents <= 0

      denom_cents = d.value * 100
      needed = balance_cents / denom_cents
      used = [needed, d.quantity].min

      next if used.zero?

      denominations[d] = used
      balance_cents -= used * denom_cents
    end

    {
      denominations: denominations,
      remaining_balance: balance_cents / 100.0
    }
  end

  def persist!(items, total_without_tax, total_tax, net_amount, change_amount, change_denominations)
    ActiveRecord::Base.transaction do
      customer = Customer.find_or_create_by!(email: @input[:email])
      apply_customer_cash! # to increment or decrement denomination given by customer acc.
      bill = Bill.create!(
        customer: customer,
        total_without_tax: total_without_tax,
        total_tax: total_tax,
        net_amount: net_amount,
        rounded_amount: net_amount.round(2),
        paid_amount: paid_amount,
        balance_amount: change_amount
      )

      items.each do |i|
        next if i[:quantity] < 1

        purchase_price = i[:product].price * i[:quantity]
        tax_amount = purchase_price * i[:product].tax_percentage / 100.0
        total_price = purchase_price + tax_amount

        BillItem.create!(
          bill: bill,
          product: i[:product],
          quantity: i[:quantity],
          unit_price: i[:product].price,
          tax_percentage: i[:product].tax_percentage,
          tax_amount: tax_amount,
          total_price: total_price
        )

        i[:product].decrement!(:stock, i[:quantity])
      end

      change_denominations.each do |denom, count|
        BillDenomination.create!(
          bill: bill,
          denomination: denom,
          count: count
        )
        denom.decrement!(:quantity, count)
      end

      bill
    end
  end

  def validate_stock!(items)
    items.filter_map do |item|
      if item[:quantity] > item[:product].stock
        {
          product_code: item[:product].product_code,
          product_name: item[:product].name,
          available: item[:product].stock
        }
      end
    end
  end

  def apply_customer_cash!
    return if @input[:denominations].blank?

    @input[:denominations].each do |value, count|
      count = count.to_i
      next if count <= 0

      denom = Denomination.find_by!(value: value.to_i)
      denom.increment!(:quantity, count)
    end
  end

  def validate_customer_cash!
    return if @input[:denominations].blank?
    denominations = @input[:denominations].to_unsafe_h

    total_cash = denominations.sum do |value, count|
      value.to_i * count.to_i
    end

    if total_cash != paid_amount
      raise "Paid amount (₹#{paid_amount}) does not match cash denominations total (₹#{total_cash})"
    end
  end

end
