class Api::V1::Items::FindController < ApplicationController
  def index
    if (params[:name] && params[:min_price]) ||
        (params[:name] && params[:max_price]) ||
        params[:name] == "" ||
        params[:min_price] == "" ||
        params[:max_price] == "" ||
        ((params[:max_price] && params[:min_price]) && (params[:min_price].to_i > params[:max_price].to_i))
      render status: 400
    elsif params[:name]
      item = Item.find_by_name(params[:name])
      if item
        render json: ItemSerializer.new(item)
      else
        render json: {data: {}}
      end
    elsif params[:min_price] && params[:max_price]
      item = Item.find_by_min_and_max_price(params[:min_price], params[:max_price])
      render json: ItemSerializer.new(item)
    elsif params[:min_price].to_i > 0
      item = Item.find_by_min_price(params[:min_price])
      if item
        render json: ItemSerializer.new(item)
      else
        render json: {data: {}}
      end
    elsif params[:max_price].to_i > 0
      item = Item.find_by_max_price(params[:max_price])
      render json: ItemSerializer.new(item)
    elsif params[:min_price].to_i < 0 || params[:max_price].to_i < 0
      render json: {error: nil}, status: 400
    end
  end
end
