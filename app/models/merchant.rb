class Merchant < ApplicationRecord
  has_many :items

  def self.find_all_by_name(search)
    where("LOWER(merchants.name) LIKE ?", "%#{search.downcase}%")
      .order(:name)
  end
end
