require "rails_helper"

RSpec.describe "BillsController", type: :request do
  # SETUP DATA
  let!(:product) do
    Product.create!(
      name: "Laptop",
      product_code: "P001",
      price: 50_000,
      tax_percentage: 18,
      stock: 10
    )
  end

  let!(:denomination) do
    Denomination.create!(value: 500, quantity: 100)
  end

  let!(:customer) do
    Customer.create!(email: "test@gmail.com")
  end

  let!(:bill) do
    Bill.create!(
      customer: customer,
      total_without_tax: 50_000,
      total_tax: 9_000,
      net_amount: 59_000,
      rounded_amount: 59_000,
      paid_amount: 60_000,
      balance_amount: 1_000
    )
  end

  # GET /bills/:id (show)
  describe "GET /bills/:id" do
    it "shows bill details" do
      get bill_path(bill)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(customer.email)
      expect(response.body).to include("Bill Summary")
    end
  end

  # GET /bills/new
  describe "GET /bills/new" do
    it "renders billing form" do
      get new_bill_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Products")
      expect(response.body).to include("Denominations")
    end
  end

  # POST /bills (create)
  describe "POST /bills" do
    context "when params are valid" do
      let(:params) do
        {
          bill: {
            email: "new@gmail.com",
            paid_amount: 60_000,
            products: [
              { product_code: "P001", quantity: 1 }
            ],
            denominations: {
              "500" => "120"
            }
          }
        }
      end

      it "creates bill successfully" do
        expect {
          post bills_path, params: params
        }.to change(Bill, :count).by(1)
      end

      it "redirects to show page" do
        post bills_path, params: params

        expect(response).to redirect_to(bill_path(Bill.last))
      end

      it "enqueues bill mailer job" do
        ActiveJob::Base.queue_adapter = :test

        expect {
          post bills_path, params: params
        }.to have_enqueued_job(BillMailerJob)
      end
    end

    context "when params are invalid" do
      let(:params) do
        {
          bill: {
            email: "",
            paid_amount: 100,
            products: [],
            denominations: {}
          }
        }
      end

      it "does not create bill" do
        expect {
          post bills_path, params: params
        }.not_to change(Bill, :count)
      end

      it "re-renders new with error" do
        post bills_path, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Email")
      end
    end
  end

  # POST /bills/preview
  describe "POST /bills/preview" do
    let(:params) do
      {
        bill: {
          email: "test@gmail.com",
          products: [
            { product_code: "P001", quantity: 1 }
          ]
        }
      }
    end

    it "returns preview calculation JSON" do
      post preview_bills_path, params: params

      json = JSON.parse(response.body)

      expect(json["total_without_tax"].to_f).to eq(50_000.0)
      expect(json["total_tax"].to_f).to eq(9_000.0)
      expect(json["net_amount"].to_f).to eq(59_000.0)
    end
  end

  # GET /bills/history
  describe "GET /bills/history" do
    it "shows previous purchases for customer" do
      get history_bills_path(email: customer.email)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(bill.id.to_s)
    end

    it "handles unknown email gracefully" do
      get history_bills_path(email: "unknown@gmail.com")

      expect(response).to have_http_status(:ok)
    end
  end
end
