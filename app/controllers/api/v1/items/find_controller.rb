class Api::V1::Items::FindController < ApplicationController
  def index
    item = Item.find_by_name(params[:name])
    render json: ItemSerializer.new(item)
  end
end
