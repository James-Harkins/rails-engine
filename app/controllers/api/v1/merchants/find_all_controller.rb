class Api::V1::Merchants::FindAllController < ApplicationController
  def index
    merchants = Merchant.where("merchants.name LIKE ?", "%#{params[:name]}%")
    render json: MerchantSerializer.new(merchants)
  end
end
