class Api::V1::Items::FindController < ApplicationController
  include Validatable

  def index
    if valid_params?(params)
      render json: get_item(params)
    else
      render json: {error: nil}, status: 400
    end
  end
end
