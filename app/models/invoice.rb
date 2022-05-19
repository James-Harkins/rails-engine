class Invoice < ApplicationRecord
  has_many :invoice_items
  has_many :items, through: :invoice_items

  def self.only_containing_item(item_id)
    all.find_all do |invoice|
      invoice.invoice_items.length == 1 && invoice.invoice_items_only_contain_item(item_id)
    end
  end

  def invoice_items_only_contain_item(item_id)
    invoice_items.all? { |invoice_item| invoice_item.item_id == item_id }
  end
end
