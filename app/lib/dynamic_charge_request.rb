require 'json'
require 'jwt'
require 'net/http'

class DynamicChargeRequest
  CLIENT_ID = Rails.application.credentials[:epoch_client_id]
  SHARED_SECRET_KEY = Rails.application.credentials[:epoch_shared_secret]
  API_URL = 'https://join.wnu.com/invoice-push'

  def initialize(invoice, base_url, status_id, member_id)
    @invoice = invoice
    @success_url = "#{base_url}/confirm/#{invoice.invoice_id}"
    @return_url = "#{base_url}/web/statuses/#{status_id}"
    @member_id = member_id
  end

  def run
    @invoice.client_id = CLIENT_ID
    @invoice.success_url = @success_url
    @invoice.return_url = @return_url
    @invoice.member_id = @member_id

    payload = @member_id.nil? ? @invoice.invoice_attributes.to_json : @invoice.invoice_attributes_cam_charge.to_json
    authorization_token = create_authorization_token(payload)
    response = Net::HTTP.post(URI(API_URL), payload, 'Authorization' => "Bearer #{authorization_token}", "Content-type" => 'application/json')

    json_content = JSON.parse(response.body)

    if json_content.key? 'success'
      json_content['redirectURL']
    else
      json_content
    end
  end

  private

  def create_authorization_token(payload)
    JWT.encode JSON.parse(payload), SHARED_SECRET_KEY
  end

end
