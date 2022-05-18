class Item < ApplicationRecord
  belongs_to :merchant
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :unit_price

  def self.find_by_name(search)
    where("LOWER(items.name) LIKE ?", "%#{search.downcase}%")
      .order(:name)
      .first
  end
end
