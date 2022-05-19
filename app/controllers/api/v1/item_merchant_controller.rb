class Api::V1::ItemMerchantController < ApplicationController
  before_action :find_item

  def index
    merchant = Merchant.find(@item.merchant_id)
    render json: MerchantSerializer.new(merchant)
  end

  private

  def find_item
    @item = begin
      Item.find(params[:item_id])
    rescue
      record_not_found
    end
  end
end
