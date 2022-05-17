FactoryBot.define do
  factory :item do
    name { Faker::TvShows::SouthPark.character }
    description { Faker::TvShows::SouthPark.quote }
    unit_price { Faker::Number.within(range: 1..100) }
  end
end
