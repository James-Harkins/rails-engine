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

      expect(merchant[:type]).to eq("merchant")

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_an(String)
    end
  end

  it "always returns an array of data, even if one resource is found" do
    create(:merchant)

    get "/api/v1/merchants"

    expect(response).to be_successful

    response_body = JSON.parse(response.body, symbolize_names: true)
    merchants = response_body[:data]

    expect(merchants).to be_an Array
    expect(merchants.count).to eq(1)
  end

  it "always returns an array of data, even if one resource is found" do
    get "/api/v1/merchants"

    expect(response).to be_successful

    response_body = JSON.parse(response.body, symbolize_names: true)
    merchants = response_body[:data]

    expect(merchants).to be_an Array
    expect(merchants.count).to eq(0)
  end

  it "can send one merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    expect(response).to be_successful

    response_body = JSON.parse(response.body, symbolize_names: true)
    merchant = response_body[:data]

    expect(merchant).to be_a Hash

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

    expect(items).to be_an Array

    items.each do |item|
      expect(item).to have_key(:id)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_an(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_an(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_an(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to eq(merchant.id)
    end
  end

  it "returns a 404 if the merchant is not found for a merchants/:id/items request" do
    get "/api/v1/merchants/1/items"

    expect(response).to have_http_status(404)
  end

  it "can find all merchants matching some case-insensitive search criteria and returns them in alphabetical order by name" do
    Merchant.create(name: "Leo Fender")
    Merchant.create(name: "Doug West")
    Merchant.create(name: "Brian Fender")
    Merchant.create(name: "Orville Gibson")
    Merchant.create(name: "Bill Fender")

    search_params = {name: "fender"}
    headers = {"CONTENT_TYPE" => "application/json"}

    get "/api/v1/merchants/find_all", headers: headers, params: search_params

    response_body = JSON.parse(response.body, symbolize_names: true)
    merchants = response_body[:data]

    expect(merchants).to be_an Array
    expect(merchants.count).to eq(3)

    merchants.each do |merchant|
      expected_names = ((merchant[:attributes][:name] == "Leo Fender") || (merchant[:attributes][:name] == "Brian Fender") || (merchant[:attributes][:name] == "Bill Fender"))
      expect(expected_names).to be true
    end
  end

  it "if the user's name search is an empty string, a 400 error is returned" do
    Merchant.create(name: "Leo Fender")
    Merchant.create(name: "Doug West")
    Merchant.create(name: "Brian Fender")
    Merchant.create(name: "Orville Gibson")
    Merchant.create(name: "Bill Fender")

    search_params = {name: ""}
    headers = {"CONTENT_TYPE" => "application/json"}

    get "/api/v1/merchants/find_all", headers: headers, params: search_params

    expect(response).to have_http_status(400)
  end
end
