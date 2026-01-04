class BillsController < ApplicationController
  def index
    @bills = Bill.order(created_at: :desc)
    respond_to do |format|
      format.html # This must be present for your test to pass
      format.json { render json: @bills }
    end
  end

  def show
    @bill = Bill.find(params[:id])
  end

  def new
    @products = Product.all
    @denominations = Denomination.all
  end

  def create
    result = Billing::Calculator.new(billing_params).call
    if result[:success]
      BillMailerJob.perform_later(result[:bill].id)
      redirect_to bill_path(result[:bill]), notice: "Bill created successfully"
    else
      flash[:error] = result[:error]
      @products = Product.all
      @denominations = Denomination.all
      render :new, status: :unprocessable_entity
    end
  end

  def preview
    result = Billing::Calculator.new(
      billing_params.merge(preview: true)
    ).call
    render json: result
  end

  def history
    @customer = Customer.find_by(email: params[:email])
    if @customer
      @bills = @customer.bills.order(created_at: :desc)

      @bills = @customer ? @customer.bills.order(created_at: :desc) : []
    end
  end


  private

  def billing_params
    params.require(:bill).permit(
      :email,
      :paid_amount,
      products: [ :product_code, :quantity ],
      denominations: {}
    )
  end
end
