require "rails_helper"

describe "Items API" do
  it "sends a list of merchants" do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)
    merchant_3 = create(:merchant)

    create_list(:item, 5, merchant_id: merchant_1.id)
    create_list(:item, 3, merchant_id: merchant_2.id)
    create_list(:item, 10, merchant_id: merchant_3.id)

    get "/api/v1/items"

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items.count).to eq(18)

    items.each do |item|
      expected_merchants = ((item[:merchant_id] == merchant_1.id) || (item[:merchant_id] == merchant_2.id) || (item[:merchant_id] == merchant_3.id))

      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(Integer)

      expect(item).to have_key(:name)
      expect(item[:name]).to be_an(String)

      expect(item).to have_key(:description)
      expect(item[:description]).to be_an(String)

      expect(item).to have_key(:unit_price)
      expect(item[:unit_price]).to be_an(Float)

      expect(item).to have_key(:merchant_id)
      expect(expected_merchants).to be true
    end
  end
end
