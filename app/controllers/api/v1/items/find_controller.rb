class Api::V1::Items::FindController < ApplicationController
  def index
    if (params[:name] && params[:min_price]) || (params[:name] && params[:max_price])
      render "results", status: 400
    elsif params[:name]
      item = Item.find_by_name(params[:name])
      render json: ItemSerializer.new(item)
    elsif params[:min_price] && params[:max_price]
      item = Item.find_by_min_and_max_price(params[:min_price], params[:max_price])
      render json: ItemSerializer.new(item)
    elsif params[:min_price].to_i > 0
      item = Item.find_by_min_price(params[:min_price])
      render json: ItemSerializer.new(item)
    elsif params[:max_price].to_i > 0
      item = Item.find_by_max_price(params[:max_price])
      render json: ItemSerializer.new(item)
    else
      render "results", status: 400
    end
  end
end
