# frozen_string_literal: true
class StatusPurchaseController < ApplicationController
  before_action :redirect_if_cant_buy!, only: [:new_transaction]
  before_action :set_status_purchase_by_id, only: [:confirm]

  def new_transaction
    status_purchase = create_pending_status_purchase
    Rails.logger.warn "new_transaction account_id: #{current_account.id}, status_id: #{status_purchase.status.id}, status_purchase_id: #{status_purchase.id}"
    redirect_to epoch_uri(@status, status_purchase)
  end

  def confirm
    # TODO: figure out a way to encode this so we don't need to create the pending transaction
    Rails.logger.warn "confirm account_id: #{current_account.id}, status_id: #{@status_purchase.status.id}, status_purchase_id: #{@status_purchase.id}, member_id: #{params[:member_id]}"

    redirect_to account_path(current_account) and return if @status_purchase.nil?
    redirect_to account_path(current_account) and return if @status_purchase.account.id != current_account.id
    redirect_to account_path(current_account) and return if params[:member_id].nil? 
    if params[:member_id] and current_account.epoch_member_id.nil?
      current_account.update(epoch_member_id: params[:member_id])
    end
    @status_purchase.update(state: :succeed)
    #TODO: don't hardcode this
    redirect_to "#{request.base_url}/web/statuses/#{@status_purchase.status.id}"
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

  def create_pending_status_purchase
    status = Status.find(params[:status_id])

    StatusPurchase.create(
      account: current_account,
      state: :pending,
      status: status,
      amount: status.cost
    )
  end

  def epoch_uri(status, status_purchase)
    DynamicChargeRequestFactory.charge_x(status.cost / 100, status_purchase.id, request.base_url, current_account.epoch_member_id)
  end

  def set_status_purchase_by_id
    @status_purchase = StatusPurchase.find(params[:reference_id])
  end
end
