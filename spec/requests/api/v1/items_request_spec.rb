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

    response_body = JSON.parse(response.body, symbolize_names: true)
    items = response_body[:data]

    expect(items.count).to eq(18)

    items.each do |item|
      expected_merchants = ((item[:attributes][:merchant_id] == merchant_1.id) || (item[:attributes][:merchant_id] == merchant_2.id) || (item[:attributes][:merchant_id] == merchant_3.id))

      expect(item).to have_key(:id)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_an(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_an(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_an(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(expected_merchants).to be true
    end
  end

  it "can send one item by its id" do
    merchant_1 = create(:merchant)

    id = create(:item, merchant_id: merchant_1.id).id

    get "/api/v1/items/#{id}"

    expect(response).to be_successful

    response_body = JSON.parse(response.body, symbolize_names: true)
    item = response_body[:data]

    expect(item).to have_key(:id)

    expect(item[:attributes]).to have_key(:name)
    expect(item[:attributes][:name]).to be_an(String)

    expect(item[:attributes]).to have_key(:description)
    expect(item[:attributes][:description]).to be_an(String)

    expect(item[:attributes]).to have_key(:unit_price)
    expect(item[:attributes][:unit_price]).to be_an(Float)

    expect(item[:attributes]).to have_key(:merchant_id)
    expect(item[:attributes][:merchant_id]).to eq(merchant_1.id)
  end

  it "can create a new item" do
    merchant_1 = create(:merchant)

    item_params = {
      name: "1959 Gibson Les Paul",
      description: "Sunburst Finish, Rosewood Fingerboard",
      unit_price: 25000000,
      merchant_id: merchant_1.id
    }
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    created_item = Item.last

    expect(response).to be_successful
    expect(created_item.name).to eq("1959 Gibson Les Paul")
    expect(created_item.description).to eq("Sunburst Finish, Rosewood Fingerboard")
    expect(created_item.unit_price).to eq(25000000)
    expect(created_item.merchant_id).to eq(merchant_1.id)
  end

  it "can update a given item" do
    merchant_1 = create(:merchant)
    id = create(:item, merchant_id: merchant_1.id).id
    previous_name = Item.last.name
    item_params = {name: "Homer Simpson"}
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate(item: item_params)

    item = Item.find(id)

    expect(response).to be_successful
    expect(item.name).to eq("Homer Simpson")
    expect(item.name).not_to eq(previous_name)
  end

  it "can delete a given item" do
    merchant_1 = create(:merchant)
    id = create(:item, merchant_id: merchant_1.id).id

    expect(Item.count).to eq(1)

    delete "/api/v1/items/#{id}"

    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect { Item.find(id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "can send merchant data for a given Item id" do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)

    item_1 = create(:item, merchant_id: merchant_2.id)
    item_2 = create(:item, merchant_id: merchant_1.id)

    get "/api/v1/items/#{item_1.id}/merchant"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchant[:name]).to eq(merchant_2.name)
    expect(merchant[:name]).not_to eq(merchant_1.name)
  end

  it "can send data for one item based on search criteria" do
    merchant_1 = create(:merchant)

    item_1 = merchant_1.items.create!(
      name: "Gibson Les Paul",
      description: "Sunburst Finish",
      unit_price: 200000
    )
    item_2 = merchant_1.items.create!(
      name: "Fender Stratocaster",
      description: "Seafoam Green Finish",
      unit_price: 100000
    )
    item_3 = merchant_1.items.create!(
      name: "Ibanez Prestige",
      description: "Black Finish",
      unit_price: 120000
    )

    search_params = {name: "Fender Stratocaster"}
    headers = {"CONTENT_TYPE" => "application/json"}

    get "/api/v1/items/find", headers: headers, params: search_params

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(item[:name]).to eq("Fender Stratocaster")
    expect(item[:name]).not_to eq("Gibson Les Paul")
    expect(item[:name]).not_to eq("Ibanez Prestige")
    expect(item[:description]).to eq("Seafoam Green Finish")
    expect(item[:description]).not_to eq("Sunburst Finish")
    expect(item[:description]).not_to eq("Black Finish")
    expect(item[:unit_price]).to eq(100000)
    expect(item[:unit_price]).not_to eq(200000)
    expect(item[:unit_price]).not_to eq(120000)
  end
end
