class Api::V1::MerchantItemsController < ApplicationController
  before_action :find_merchant

  def index
    render json: ItemSerializer.new(@merchant.items)
  end

  private

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
