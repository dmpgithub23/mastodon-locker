class DynamicChargeRequestFactory
  def self.charge_x(amount, reference_id, base_url, member_id)
    invoice = InvoiceFactory.with_one_position(amount, reference_id)
    DynamicChargeRequest.new(invoice, base_url, reference_id, member_id).run
  end
end
