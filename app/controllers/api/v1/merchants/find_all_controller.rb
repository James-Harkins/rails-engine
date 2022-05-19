class Api::V1::Merchants::FindAllController < ApplicationController
  def index
    if params[:name] != ""
      merchants = Merchant.find_all_by_name(params[:name])
      render json: MerchantSerializer.new(merchants)
    else
      render status: 400
    end
  end
end
