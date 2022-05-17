class Api::V1::Merchants::FindAllController < ApplicationController
  def index
    render json: Merchant.where("merchants.name LIKE ?", "%#{params[:name]}%")
  end
end
