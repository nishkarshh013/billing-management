require "rails_helper"

RSpec.describe Billing::Calculator, type: :service do
  # Test Data
  let!(:product) do
    Product.create!(
      name: "Laptop",
      product_code: "P001",
      price: 50_000,
      tax_percentage: 18,
      stock: 10
    )
  end

  let!(:denomination_500) { Denomination.create!(value: 500, quantity: 10) }
  let!(:denomination_100) { Denomination.create!(value: 100, quantity: 10) }

  let(:input) do
    {
      email: "test@gmail.com",
      products: [ { product_code: "P001", quantity: 1 } ],
      paid_amount: 60_000
    }
  end

  subject(:service_call) { described_class.new(input).call }

  # SUCCESS CASES
  describe "successful billing" do
    it "creates bill successfully" do
      result = service_call
      expect(result[:success]).to eq(true)
      expect(result[:bill]).to be_present
    end

    it "calculates bill totals correctly" do
      bill = service_call[:bill]

      expect(bill.total_without_tax).to eq(50_000)
      expect(bill.total_tax).to eq(9_000)
      expect(bill.net_amount).to eq(59_000)
      expect(bill.rounded_amount).to eq(59_000)
      expect(bill.balance_amount).to eq(1_000)
    end

    it "creates correct bill item totals" do
      item = service_call[:bill].bill_items.first

      expect(item.unit_price).to eq(50_000)
      expect(item.quantity).to eq(1)
      expect(item.tax_amount).to eq(9_000)
      expect(item.total_price).to eq(59_000) # purchase + tax
    end

    it "reduces product stock" do
      expect { service_call }
        .to change { product.reload.stock }
        .from(10).to(9)
    end

    it "creates denomination entries when possible" do
      bill = service_call[:bill]

      expect(bill.bill_denominations.sum(:count)).to be > 0
    end

    it "reduces denomination quantities" do
      expect { service_call }
        .to change { denomination_500.reload.quantity }
        .by(-2)
    end
  end

  # FAILURE CASES
  context "when payment is insufficient" do
    let(:input) do
      {
        email: "test@gmail.com",
        products: [ { product_code: "P001", quantity: 1 } ],
        paid_amount: 1_000
      }
    end

    it "fails with payment error" do
      result = service_call

      expect(result[:success]).to eq(false)
      expect(result[:error]).to eq("Insufficient payment")
    end
  end

  context "when stock is insufficient" do
    let(:input) do
      {
        email: "test@gmail.com",
        products: [ { product_code: "P001", quantity: 100 } ],
        paid_amount: 60_000
      }
    end

    it "fails with stock error" do
      result = service_call

      expect(result[:success]).to eq(false)
      expect(result[:error]).to match(/only 10 left/)
    end
  end

  # NON-FATAL CASE
  context "when exact change cannot be returned" do
    before do
      denomination_500.update!(quantity: 0)
      denomination_100.update!(quantity: 0)
    end

    it "still creates bill but leaves balance unpaid" do
      result = service_call
      bill = result[:bill]

      expect(result[:success]).to eq(true)
      expect(bill).to be_present
      expect(bill.balance_amount).to eq(1_000)
      expect(bill.bill_denominations).to be_empty
    end
  end
end
