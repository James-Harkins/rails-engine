class Api::V1::Items::FindController < ApplicationController
  def index
    if (params[:name] && params[:min_price]) || (params[:name] && params[:max_price])
      invalid_params
    elsif params[:name]
      item = Item.find_by_name(params[:name])
    elsif params[:min_price] && params[:max_price]
      item = Item.find_by_min_and_max_price(params[:min_price], params[:max_price])
    elsif params[:min_price]
      item = Item.find_by_min_price(params[:min_price])
    elsif params[:max_price]
      item = Item.find_by_max_price(params[:max_price])
    end
    render json: ItemSerializer.new(item)
  end
end
