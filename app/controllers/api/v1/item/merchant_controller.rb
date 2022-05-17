class Api::V1::Item::MerchantController < ApplicationController
  def index
    item = Item.find(params[:item_id])
    render json: item.merchant
  end
end
