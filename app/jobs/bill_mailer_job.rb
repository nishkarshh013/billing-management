class BillMailerJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 10.seconds, attempts: 5

  def perform(bill_id)
    BillMailer.invoice(bill_id).deliver_now    
  end
end
