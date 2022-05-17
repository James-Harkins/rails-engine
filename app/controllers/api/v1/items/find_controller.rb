class Api::V1::Items::FindController < ApplicationController
  def index
    render json: Item.where(name: params[:name]).first
  end
end
