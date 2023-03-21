class InvoiceFactory
  def self.with_one_position(amount, site, status_id, account_id)
    reference_id = status_id.to_s + "-" + account_id.to_s
    invoice = Invoice.new(reference_id)
    invoice.add_purchase(Purchase.new(amount, site))
    invoice
  end
end

class Invoice
  attr_writer :client_id
  attr_reader :purchases, :invoice_id
  attr_accessor :success_url, :return_url, :member_id

  def initialize(invoice_id)
    @invoice_id = invoice_id.to_s
    @purchases = []
  end

  def add_purchase(purchase)
    @purchases << purchase
  end

  def invoice_attributes
    {
      client_id: @client_id,
      invoice_id: @invoice_id,
      purchases: @purchases.map(&:purchase_attributes),
      success_url: @success_url,
      return_url: @return_url,
    }
  end

  def invoice_attributes_cam_charge
    {
      client_id: @client_id,
      invoice_id: @invoice_id,
      member_id: @member_id,
      type: "camcharge",
      purchases: @purchases.map(&:purchase_attributes),
      success_url: @success_url,
      return_url: @return_url,
    }
  end

end

class Purchase
  attr_reader :amount

  def initialize(amount, site)
    @amount = amount
    @site = site
  end

  def purchase_attributes
    {
      site: @site,
      #site: 'www.bigbuttbouncetwerk.com',
      billing: {
        currency: 'USD',
        initial: {
          amount: @amount,
        },
      },
    }
  end
end

