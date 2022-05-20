class Api::V1::Items::FindController < ApplicationController
  def index
    if valid_params?(params)
      render json: get_item(params)
    else
      render json: {error: nil}, status: 400
    end
  end

  private

  def valid_params?(params)
    return false if params[:name] && (!params[:min_price].nil? || !params[:max_price].nil?)
    return false if params_empty?(params, [:name, :min_price, :max_price])
    return false if (!params[:max_price].nil? && !params[:min_price].nil?) && (params[:min_price].to_i > params[:max_price].to_i)
    return false if params[:min_price].to_i < 0 || params[:max_price].to_i < 0
    true
  end

  def params_empty?(params, checked_params)
    checked_params.any? do |param|
      params[param] == ""
    end
  end

  def find_by_name(name)
    item = Item.find_by_name(name)
    item ? ItemSerializer.new(item) : {data: {}}
  end

  def find_by_price(min_price, max_price)
    item = Item.find_by_min_and_max_price(min_price, max_price)
    item ? ItemSerializer.new(item) : {data: {}}
  end

  def get_item(params)
    if params[:name]
      find_by_name(params[:name])
    else
      find_by_price(params[:min_price], params[:max_price])
    end
  end
end
