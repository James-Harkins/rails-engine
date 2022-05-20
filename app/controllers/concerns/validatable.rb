module Validatable
  def valid_params?(params)
    return false if name_and_price?(params)
    return false if params_empty?(params, [:name, :min_price, :max_price])
    return false if min_greater_than_max?(params)
    return false if params_less_than_zero?(params)
    true
  end

  def name_and_price?(params)
    params[:name] && (!params[:min_price].nil? || !params[:max_price].nil?)
  end

  def params_empty?(params, checked_params)
    checked_params.any? do |param|
      params[param] == ""
    end
  end

  def min_greater_than_max?(params)
    (!params[:max_price].nil? && !params[:min_price].nil?) && (params[:min_price].to_i > params[:max_price].to_i)
  end

  def params_less_than_zero?(params)
    params[:min_price].to_i < 0 || params[:max_price].to_i < 0
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
