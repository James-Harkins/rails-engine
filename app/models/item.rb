class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items

  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :unit_price

  def self.find_by_name(search)
    where("LOWER(items.name) LIKE ?", "%#{search.downcase}%")
      .order(:name)
      .first
  end

  def self.find_by_min_price(min_price)
    where("items.unit_price > ?", min_price)
      .order(:name)
      .first
  end

  def self.find_by_max_price(max_price)
    where("items.unit_price < ?", max_price)
      .order(:name)
      .first
  end

  def self.find_by_min_and_max_price(min_price, max_price)
    min_price ||= 0
    max_price ||= Float::INFINITY
    where("items.unit_price > ? AND items.unit_price < ?", min_price, max_price)
      .order(:name)
      .first
  end
end
