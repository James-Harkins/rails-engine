require "rails_helper"

describe "Merchants API" do
  it "sends a list of merchants" do
    create_list(:merchant, 5)

    get "/api/v1/merchants"

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants.count).to eq(5)

    merchants.each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_an(Integer)

      expect(merchant).to have_key(:name)
      expect(merchant[:name]).to be_an(String)
    end
  end

  it "can send one merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    expect(response).to be_successful

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(merchant).to have_key(:id)
    expect(merchant[:id]).to be_an(Integer)

    expect(merchant).to have_key(:name)
    expect(merchant[:name]).to be_an(String)
  end

  it "can get all items for one merchant" do
    merchant = create(:merchant)

    create_list(:item, 5, merchant_id: merchant.id)

    get "/api/v1/merchants/#{merchant.id}/items"

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    items.each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(Integer)

      expect(item).to have_key(:name)
      expect(item[:name]).to be_an(String)

      expect(item).to have_key(:description)
      expect(item[:description]).to be_an(String)

      expect(item).to have_key(:unit_price)
      expect(item[:unit_price]).to be_an(Float)

      expect(item).to have_key(:merchant_id)
      expect(item[:merchant_id]).to eq(merchant.id)
    end
  end

  it "can find all merchants matching some search criteria" do
    merchant_1 = Merchant.create(name: "Leo Fender")
    merchant_2 = Merchant.create(name: "Doug West")
    merchant_3 = Merchant.create(name: "Brian Fender")
    merchant_4 = Merchant.create(name: "Orville Gibson")
    merchant_5 = Merchant.create(name: "Bill Fender")

    search_params = {name: "Fender"}
    headers = {"CONTENT_TYPE" => "application/json"}

    get "/api/v1/merchants/find_all", headers: headers, params: search_params

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants.count).to eq(3)

    merchants.each do |merchant|
      expected_names = ((merchant[:name] == "Leo Fender") || (merchant[:name] == "Brian Fender") || (merchant[:name] == "Bill Fender"))
      expect(expected_names).to be true
    end
  end
end
