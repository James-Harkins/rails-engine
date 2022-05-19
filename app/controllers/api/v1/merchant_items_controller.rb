class Api::V1::MerchantItemsController < ApplicationController
  before_action :find_merchant

  def index
    render json: ItemSerializer.new(@merchant.items)
  end

  private

  def find_merchant
    @merchant = begin
      Merchant.find(params[:merchant_id])
    rescue
      record_not_found
    end
  end
end
