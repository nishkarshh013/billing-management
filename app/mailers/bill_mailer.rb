class BillMailer < ApplicationMailer
  def invoice(bill_id)
     @bill = Bill.includes(
        :customer,
        :bill_items => :product,
        :bill_denominations => :denomination
      ).find(bill_id)

    mail(
      to: @bill.customer.email,
      subject: "Your bill ##{@bill.id}"
    )
  end
end
