class Item < ApplicationRecord
  belongs_to :merchant

  attr_accessor :post_or_patch

  def self.find_by_name(search)
    where("LOWER(items.name) LIKE ?", "%#{search.downcase}%")
      .order(:name)
      .first
  end
end
