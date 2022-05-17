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

  it "can send one item by its id" do
    merchant_1 = create(:merchant)

    id = create(:item, merchant_id: merchant_1.id).id

    get "/api/v1/items/#{id}"

    expect(response).to be_successful

    item = JSON.parse(response.body, symbolize_names: true)

    expect(item).to have_key(:id)
    expect(item[:id]).to be_an(Integer)

    expect(item).to have_key(:name)
    expect(item[:name]).to be_an(String)

    expect(item).to have_key(:description)
    expect(item[:description]).to be_an(String)

    expect(item).to have_key(:unit_price)
    expect(item[:unit_price]).to be_an(Float)

    expect(item).to have_key(:merchant_id)
    expect(item[:merchant_id]).to eq(merchant_1.id)
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
    expect(Item.find(id)).to raise_error(ActiveRecord::RecordNotFound)
  end
end
