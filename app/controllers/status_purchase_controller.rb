# frozen_string_literal: true
class StatusPurchaseController < ApplicationController
  before_action :redirect_if_cant_buy!, only: [:new_transaction]
  before_action :set_purchase_params, only: [:confirm]

  def new_transaction
    status = Status.find(params[:status_id])
    Rails.logger.warn "new_transaction account_id: #{current_account.id}, status_id: #{status.id}"
    redirect_to epoch_uri(status)
  end

  def confirm
    Rails.logger.warn "confirm account_id: #{current_account.id}, status_id: #{@status.id}, member_id: #{@member_id}, is_secure: #{@is_secure}"

    redirect_to account_path(current_account) and return if @is_secure == false
    redirect_to account_path(current_account) and return if @status.nil?
    redirect_to account_path(current_account) and return if @param_account.id != current_account.id
    redirect_to account_path(current_account) and return if @member_id.nil? 
    if @member_id and current_account.epoch_member_id.nil?
      current_account.update(epoch_member_id: @member_id)
    end
    StatusPurchase.create(
      account: current_account,
      state: :succeed,
      status: @status,
      amount: @status.cost
    )
    #TODO: don't hardcode this
    redirect_to "#{request.base_url}/web/statuses/#{@status.id}"
  end

  private

  def redirect_if_cant_buy!
    @status = Status.find(params[:status_id])
    if @status.nil?
      flash[:error] = "Post not found!"
      return redirect_to account_path current_account
    end
    if @status.unlocked_for?(current_account.id)
      flash[:error] = "Already unlocked!"
      redirect_to account_path(status.account)
    end
  end

  def epoch_uri(status)
    site = ENV["BILLING_SITE_URL"]
    DynamicChargeRequestFactory.charge_x(status, current_account, request.base_url, site, get_security_hash(status, current_account))
  end

  def set_purchase_params
    @status = Status.find(params[:status_id])
    @param_account = Account.find(params[:account_id])
    @is_secure = get_security_hash(@status, @param_account) == params[:security_hash]
    @member_id = params[:member_id]
  end

  def get_security_hash(status, account)
    hmac = Rails.env.development? ? 'testhmac' : Rails.application.credentials[:epoch_hmac]
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('md5'), hmac, status.id.to_s + account.id.to_s)
  end

end
