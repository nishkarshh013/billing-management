# # spec/controllers/bills_controller_spec.rb
# require 'rails_helper'

# RSpec.describe BillsController, type: :controller do
#   let(:customer) { create(:customer, email: 'test@example.com') }
#   let(:product) { create(:product, product_code: 'P001', price: 100, stock: 10, tax_percentage: 10) }
#   let(:denomination) { create(:denomination, value: 500, quantity: 10) }
#   let(:bill) { create(:bill, customer: customer) }

#   describe 'GET #index' do
#     it 'returns a successful response' do
#       get :index
#       expect(response).to be_successful
#     end

#     it 'assigns @bills ordered by created_at desc' do
#       bill1 = create(:bill, customer: customer, created_at: 1.day.ago)
#       bill2 = create(:bill, customer: customer, created_at: 2.days.ago)
#       bill3 = create(:bill, customer: customer, created_at: Time.current)
      
#       get :index
#       expect(assigns(:bills)).to eq([bill3, bill1, bill2])
#     end

#     it 'renders the index template' do
#       get :index
#       expect(response).to render_template(:index)
#     end
#   end

#   describe 'GET #show' do
#     it 'returns a successful response' do
#       get :show, params: { id: bill.id }
#       expect(response).to be_successful
#     end

#     it 'assigns the requested bill to @bill' do
#       get :show, params: { id: bill.id }
#       expect(assigns(:bill)).to eq(bill)
#     end

#     it 'renders the show template' do
#       get :show, params: { id: bill.id }
#       expect(response).to render_template(:show)
#     end

#     it 'raises error for invalid bill id' do
#       expect {
#         get :show, params: { id: 'invalid' }
#       }.to raise_error(ActiveRecord::RecordNotFound)
#     end
#   end

#   describe 'GET #new' do
#     before do
#       product
#       denomination
#     end

#     it 'returns a successful response' do
#       get :new
#       expect(response).to be_successful
#     end

#     it 'assigns all products to @products' do
#       get :new
#       expect(assigns(:products)).to include(product)
#     end

#     it 'assigns all denominations to @denominations' do
#       get :new
#       expect(assigns(:denominations)).to include(denomination)
#     end

#     it 'renders the new template' do
#       get :new
#       expect(response).to render_template(:new)
#     end
#   end

#   describe 'POST #create' do
#     let(:valid_params) do
#       {
#         email: 'customer@example.com',
#         paid_amount: 150,
#         products: [
#           { product_code: product.product_code, quantity: 1 }
#         ]
#       }
#     end

#     let(:invalid_params) do
#       {
#         email: 'customer@example.com',
#         paid_amount: 50,
#         products: [
#           { product_code: product.product_code, quantity: 1 }
#         ]
#       }
#     end

#     before do
#       product
#       create(:denomination, value: 100, quantity: 10)
#       create(:denomination, value: 50, quantity: 10)
#       create(:denomination, value: 20, quantity: 10)
#     end

#     context 'with valid parameters' do
#       it 'creates a new bill' do
#         expect {
#           post :create, params: valid_params
#         }.to change(Bill, :count).by(1)
#       end

#       it 'creates a new customer if not exists' do
#         expect {
#           post :create, params: valid_params
#         }.to change(Customer, :count).by(1)
#       end

#       it 'creates bill items' do
#         expect {
#           post :create, params: valid_params
#         }.to change(BillItem, :count).by(1)
#       end

#       it 'decrements product stock' do
#         expect {
#           post :create, params: valid_params
#         }.to change { product.reload.stock }.by(-1)
#       end

#       it 'redirects to the bill show page' do
#         post :create, params: valid_params
#         expect(response).to redirect_to(bill_path(Bill.last))
#       end

#       it 'sets a success notice' do
#         post :create, params: valid_params
#         expect(flash[:notice]).to eq('Bill created successfully')
#       end
#     end

#     context 'with invalid parameters (insufficient payment)' do
#       it 'does not create a new bill' do
#         expect {
#           post :create, params: invalid_params
#         }.not_to change(Bill, :count)
#       end

#       it 'sets an error message' do
#         post :create, params: invalid_params
#         expect(flash[:error]).to be_present
#       end

#       it 'assigns @products' do
#         post :create, params: invalid_params
#         expect(assigns(:products)).to be_present
#       end

#       it 'assigns @denominations' do
#         post :create, params: invalid_params
#         expect(assigns(:denominations)).to be_present
#       end

#       it 'renders the new template' do
#         post :create, params: invalid_params
#         expect(response).to render_template(:new)
#       end

#       it 'returns unprocessable entity status' do
#         post :create, params: invalid_params
#         expect(response).to have_http_status(:unprocessable_entity)
#       end
#     end

#     context 'with out of stock product' do
#       let(:out_of_stock_params) do
#         {
#           email: 'customer@example.com',
#           paid_amount: 1500,
#           products: [
#             { product_code: product.product_code, quantity: 100 }
#           ]
#         }
#       end

#       it 'does not create a bill' do
#         expect {
#           post :create, params: out_of_stock_params
#         }.not_to change(Bill, :count)
#       end

#       it 'sets an error message' do
#         post :create, params: out_of_stock_params
#         expect(flash[:error]).to match(/Out of stock/)
#       end

#       it 'does not change product stock' do
#         expect {
#           post :create, params: out_of_stock_params
#         }.not_to change { product.reload.stock }
#       end
#     end

#     context 'with non-existent product' do
#       let(:invalid_product_params) do
#         {
#           email: 'customer@example.com',
#           paid_amount: 150,
#           products: [
#             { product_code: 'INVALID', quantity: 1 }
#           ]
#         }
#       end

#       it 'does not create a bill' do
#         expect {
#           post :create, params: invalid_product_params
#         }.not_to change(Bill, :count)
#       end

#       it 'sets an error message' do
#         post :create, params: invalid_product_params
#         expect(flash[:error]).to be_present
#       end
#     end

#     context 'with multiple products' do
#       let(:another_product) { create(:product, product_code: 'P002', price: 50, stock: 5, tax_percentage: 12) }
#       let(:multi_product_params) do
#         {
#           email: 'customer@example.com',
#           paid_amount: 300,
#           products: [
#             { product_code: product.product_code, quantity: 1 },
#             { product_code: another_product.product_code, quantity: 2 }
#           ]
#         }
#       end

#       before { another_product }

#       it 'creates bill with multiple items' do
#         expect {
#           post :create, params: multi_product_params
#         }.to change(BillItem, :count).by(2)
#       end

#       it 'calculates correct total' do
#         post :create, params: multi_product_params
#         bill = Bill.last
#         # Product 1: 100 + 10% tax = 110
#         # Product 2: 100 (50*2) + 12% tax = 112
#         # Total: 222
#         expect(bill.net_amount).to eq(222)
#       end
#     end

#     context 'when change cannot be returned exactly' do
#       let(:exact_change_params) do
#         {
#           email: 'customer@example.com',
#           paid_amount: 111,
#           products: [
#             { product_code: product.product_code, quantity: 1 }
#           ]
#         }
#       end

#       before do
#         # Only large denominations available
#         Denomination.destroy_all
#         create(:denomination, value: 100, quantity: 10)
#       end

#       it 'does not create a bill' do
#         expect {
#           post :create, params: exact_change_params
#         }.not_to change(Bill, :count)
#       end

#       it 'sets error about change' do
#         post :create, params: exact_change_params
#         expect(flash[:error]).to match(/Cannot return exact change/)
#       end
#     end
#   end
# end