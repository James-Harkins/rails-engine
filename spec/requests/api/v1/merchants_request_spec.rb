require "rails_helper"

describe "Merchants API" do
  it "sends a list of merchants" do
    create_list(:merchant, 5)

    get "/api/v1/merchants"

    expect(response).to be_successful

    response_body = JSON.parse(response.body, symbolize_names: true)
    merchants = response_body[:data]

    expect(merchants.count).to eq(5)

    merchants.each do |merchant|
      expect(merchant).to have_key(:id)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_an(String)
    end
  end

  it "can send one merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    expect(response).to be_successful

    response_body = JSON.parse(response.body, symbolize_names: true)
    merchant = response_body[:data]

    expect(merchant).to have_key(:id)

    expect(merchant[:attributes]).to have_key(:name)
    expect(merchant[:attributes][:name]).to be_an(String)
  end

  it "can get all items for one merchant" do
    merchant = create(:merchant)

    create_list(:item, 5, merchant_id: merchant.id)

    get "/api/v1/merchants/#{merchant.id}/items"

    expect(response).to be_successful

    response_body = JSON.parse(response.body, symbolize_names: true)
    items = response_body[:data]

    items.each do |item|
      expect(item).to have_key(:id)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_an(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_an(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_an(Float)
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

    response_body = JSON.parse(response.body, symbolize_names: true)
    merchants = response_body[:data]

    expect(merchants.count).to eq(3)

    merchants.each do |merchant|
      expected_names = ((merchant[:attributes][:name] == "Leo Fender") || (merchant[:attributes][:name] == "Brian Fender") || (merchant[:attributes][:name] == "Bill Fender"))
      expect(expected_names).to be true
    end
  end
end
