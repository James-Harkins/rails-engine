class Invoice < ApplicationRecord
  has_many :invoice_items
  has_many :items, through: :invoice_items

  def self.only_containing_item(item_id)
    all.find_all do |invoice|
      invoice.invoice_items.length == 1
    end
  end
end
