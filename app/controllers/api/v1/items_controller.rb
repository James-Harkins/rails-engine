class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    item = Item.new(item_params)
    if item.save
      render json: ItemSerializer.new(item)
    else
      render json: ErrorSerializer.serialize(item.errors)
    end
  end

  def update
    item = Item.update(params[:id], item_params)
    render json: ItemSerializer.new(item)
  end

  def destroy
    item = Item.find(params[:id])
    Invoice.only_containing_item(item.id).each do |invoice|
      invoice.invoice_items.each { |invoice_item| invoice_item.destroy }
      invoice.destroy
    end
    item.invoice_items.each { |invoice_item| invoice_item.destroy }
    Item.destroy(params[:id])
    render body: nil, status: :no_content
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
