class Api::V1::Merchants::FindAllController < ApplicationController
  def index
    merchants = Merchant.find_all_by_name(params[:name])
    render json: MerchantSerializer.new(merchants)
  end
end
