FactoryBot.define do
  factory :merchant do
    name { Faker::Fantasy::Tolkien.character }
  end
end
