class Api::V1::Items::FindController < ApplicationController
  def index
    render json: Item.where("items.name LIKE ?", "%#{params[:name]}%")
      .order(:name)
      .first
  end
end
