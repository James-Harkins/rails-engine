class Api::V1::Items::FindController < ApplicationController
  def index
    item = Item.where("items.name LIKE ?", "%#{params[:name]}%")
      .order(:name)
      .first
    render json: ItemSerializer.new(item)
  end
end
