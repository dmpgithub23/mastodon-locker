class DynamicChargeRequestFactory
  def self.charge_x(status, account, base_url, site, security_hash)
    invoice = InvoiceFactory.with_one_position(status.cost / 100, site, status.id, account.id)
    DynamicChargeRequest.new(invoice, base_url, status.id, account.id, security_hash, account.epoch_member_id).run
  end
end
