class Api::V1::Merchant::ItemsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: merchant.items
  end
end