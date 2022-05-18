class Item < ApplicationRecord
  belongs_to :merchant

  def self.find_by_name(search)
    where("LOWER(items.name) LIKE ?", "%#{search}%")
      .order(:name)
      .first
  end
end
