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
      expect(item).to have_key(:id)
      expect(item[:type]).to eq("item")

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_an(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_an(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_an(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
    end
  end

  it "always returns an array of data, even if one resource is found" do
    merchant = create(:merchant)

    create(:item, merchant_id: merchant.id)

    get "/api/v1/items"

    expect(response).to be_successful

    response_body = JSON.parse(response.body, symbolize_names: true)
    items = response_body[:data]

    expect(items).to be_an Array
    expect(items.count).to eq(1)
  end

  it "always returns an array of data, even if one resource is found" do
    get "/api/v1/items"

    expect(response).to be_successful

    response_body = JSON.parse(response.body, symbolize_names: true)
    items = response_body[:data]

    expect(items).to be_an Array
    expect(items.count).to eq(0)
  end

  it "can send one item by its id" do
    merchant_1 = create(:merchant)

    id = create(:item, merchant_id: merchant_1.id).id

    get "/api/v1/items/#{id}"

    expect(response).to be_successful

    response_body = JSON.parse(response.body, symbolize_names: true)
    item = response_body[:data]

    expect(item).to be_a Hash

    expect(item).to have_key(:id)

    expect(item[:attributes]).to have_key(:name)
    expect(item[:attributes][:name]).to be_an(String)

    expect(item[:attributes]).to have_key(:description)
    expect(item[:attributes][:description]).to be_an(String)

    expect(item[:attributes]).to have_key(:unit_price)
    expect(item[:attributes][:unit_price]).to be_an(Float)

    expect(item[:attributes]).to have_key(:merchant_id)
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

    response_body = JSON.parse(response.body, symbolize_names: true)
    item = response_body[:data]

    expect(response).to be_successful
    expect(item[:attributes][:name]).to eq("1959 Gibson Les Paul")
    expect(item[:attributes][:description]).to eq("Sunburst Finish, Rosewood Fingerboard")
    expect(item[:attributes][:unit_price]).to eq(25000000)
    expect(item[:attributes][:merchant_id]).to eq(merchant_1.id)
  end

  it "returns an error if any attribute is missing" do
    merchant_1 = create(:merchant)

    item_params = {
      name: "1959 Gibson Les Paul",
      unit_price: 25000000,
      merchant_id: merchant_1.id
    }
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    response_body = JSON.parse(response.body, symbolize_names: true)

    expect(response_body).to be_a Hash
    expect(response_body[:errors]).to be_an Array
    expect(response_body[:errors][0]).to be_a Hash
    expect(response_body[:errors][0][:id]).to eq("description")
    expect(response_body[:errors][0][:title]).to eq("Description can't be blank")
  end

  it "ignores attributes sent by the user which are not allowed" do
    merchant_1 = create(:merchant)

    item_params = {
      name: "1959 Gibson Les Paul",
      description: "Sunburst Finish, Rosewood Fingerboard",
      unit_price: 25000000,
      merchant_id: merchant_1.id,
      num_of_strings: 6,
      num_of_frets: 22
    }
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    response_body = JSON.parse(response.body, symbolize_names: true)
    item = response_body[:data]

    expect(response).to be_successful
    expect(item[:attributes][:name]).to eq("1959 Gibson Les Paul")
    expect(item[:attributes][:description]).to eq("Sunburst Finish, Rosewood Fingerboard")
    expect(item[:attributes][:unit_price]).to eq(25000000)
    expect(item[:attributes][:merchant_id]).to eq(merchant_1.id)
    expect(item[:attributes]).not_to have_key(:num_of_strings)
    expect(item[:attributes]).not_to have_key(:num_of_frets)
  end

  it "can update a given item" do
    merchant_1 = create(:merchant)
    id = create(:item, merchant_id: merchant_1.id).id
    previous_name = Item.last.name
    item_params = {name: "Homer Simpson"}
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate(item: item_params)

    response_body = JSON.parse(response.body, symbolize_names: true)
    item = response_body[:data]

    expect(response).to be_successful
    expect(item[:attributes][:name]).to eq("Homer Simpson")
    expect(item[:attributes][:name]).not_to eq(previous_name)
    expect(item[:attributes][:merchant_id]).to eq(merchant_1.id)
  end

  it "can delete a given item" do
    merchant_1 = create(:merchant)
    id = create(:item, merchant_id: merchant_1.id).id

    expect(Item.count).to eq(1)

    delete "/api/v1/items/#{id}"

    expect(response).to have_http_status(204)
  end

  it "when an item is deleted, all invoices where the deleted item was the only item are destroyed" do
    merchant_1 = create(:merchant)

    item_1 = merchant_1.items.create!(
      name: "Gibson Les Paul",
      description: "Sunburst Finish",
      unit_price: 200000
    )
    item_2 = merchant_1.items.create!(
      name: "Fender Telecaster",
      description: "Butterscotch Blonde Finish",
      unit_price: 130000
    )
    item_3 = merchant_1.items.create!(
      name: "Fender Stratocaster",
      description: "Seafoam Green Finish",
      unit_price: 100000
    )
    item_4 = merchant_1.items.create!(
      name: "Ibanez Prestige",
      description: "Black Finish",
      unit_price: 120000
    )

    invoice_1 = Invoice.create!
    invoice_2 = Invoice.create!
    invoice_3 = Invoice.create!
    invoice_4 = Invoice.create!
    invoice_5 = Invoice.create!
    invoice_6 = Invoice.create!

    InvoiceItem.create!(invoice: invoice_1, item: item_1)
    InvoiceItem.create!(invoice: invoice_1, item: item_3)

    InvoiceItem.create!(invoice: invoice_2, item: item_4)

    InvoiceItem.create!(invoice: invoice_3, item: item_2)
    InvoiceItem.create!(invoice: invoice_3, item: item_1)

    InvoiceItem.create!(invoice: invoice_4, item: item_1)

    InvoiceItem.create!(invoice: invoice_5, item: item_4)

    InvoiceItem.create!(invoice: invoice_6, item: item_1)
    InvoiceItem.create!(invoice: invoice_6, item: item_4)

    delete "/api/v1/items/#{item_4.id}"

    expect(Invoice.find(invoice_1.id)).to eq(invoice_1)
    expect { Invoice.find(invoice_2.id) }.to raise_error(ActiveRecord::RecordNotFound)
    expect(Invoice.find(invoice_3.id)).to eq(invoice_3)
    expect(Invoice.find(invoice_4.id)).to eq(invoice_4)
    expect { Invoice.find(invoice_5.id) }.to raise_error(ActiveRecord::RecordNotFound)
    expect(Invoice.find(invoice_6.id)).to eq(invoice_6)
  end

  it "can send merchant data for a given Item id" do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)

    item_1 = create(:item, merchant_id: merchant_2.id)
    item_2 = create(:item, merchant_id: merchant_1.id)

    get "/api/v1/items/#{item_1.id}/merchant"

    response_body = JSON.parse(response.body, symbolize_names: true)
    merchant = response_body[:data]

    expect(merchant).to be_a Hash

    expect(response).to be_successful
    expect(merchant[:attributes][:name]).to eq(merchant_2.name)
    expect(merchant[:attributes][:name]).not_to eq(merchant_1.name)
  end

  it "returns a 404 if the item is not found for an items/:id/merchant request" do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)

    item_1 = create(:item, merchant_id: merchant_2.id)
    item_2 = create(:item, merchant_id: merchant_1.id)
    item_3 = create(:item, merchant_id: merchant_1.id)
    id = item_3.id
    item_3.destroy

    get "/api/v1/items/#{id}/merchant"

    expect(response).to have_http_status(404)
  end

  it "can send data for one item based on name search criteria, which is case-insensitive and returns the first item alphabetically by name" do
    merchant_1 = create(:merchant)

    merchant_1.items.create!(
      name: "Gibson Les Paul",
      description: "Sunburst Finish",
      unit_price: 200000
    )
    merchant_1.items.create!(
      name: "Fender Telecaster",
      description: "Butterscotch Blonde Finish",
      unit_price: 130000
    )
    merchant_1.items.create!(
      name: "Fender Stratocaster",
      description: "Seafoam Green Finish",
      unit_price: 100000
    )
    merchant_1.items.create!(
      name: "Ibanez Prestige",
      description: "Black Finish",
      unit_price: 120000
    )

    search_params = {name: "fender"}
    headers = {"CONTENT_TYPE" => "application/json"}

    get "/api/v1/items/find", headers: headers, params: search_params

    response_body = JSON.parse(response.body, symbolize_names: true)
    item = response_body[:data]

    expect(response).to be_successful

    expect(item).to be_a Hash

    expect(item[:attributes][:name]).to eq("Fender Stratocaster")
    expect(item[:attributes][:name]).not_to eq("Gibson Les Paul")
    expect(item[:attributes][:name]).not_to eq("Ibanez Prestige")
    expect(item[:attributes][:name]).not_to eq("Fender Telecaster")

    expect(item[:attributes][:description]).to eq("Seafoam Green Finish")
    expect(item[:attributes][:description]).not_to eq("Sunburst Finish")
    expect(item[:attributes][:description]).not_to eq("Black Finish")
    expect(item[:attributes][:description]).not_to eq("Butterscotch Blonde Finish")

    expect(item[:attributes][:unit_price]).to eq(100000)
    expect(item[:attributes][:unit_price]).not_to eq(200000)
    expect(item[:attributes][:unit_price]).not_to eq(120000)
    expect(item[:attributes][:unit_price]).not_to eq(130000)

    expect(item[:attributes][:merchant_id]).to eq(merchant_1.id)
  end

  it "can send one item based on minimum price search criteria, which returns the first item alphabetically by name" do
    merchant_1 = create(:merchant)

    merchant_1.items.create!(
      name: "Gibson Les Paul",
      description: "Sunburst Finish",
      unit_price: 200000
    )
    merchant_1.items.create!(
      name: "Fender Telecaster",
      description: "Butterscotch Blonde Finish",
      unit_price: 130000
    )
    merchant_1.items.create!(
      name: "Fender Stratocaster",
      description: "Seafoam Green Finish",
      unit_price: 100000
    )
    merchant_1.items.create!(
      name: "Ibanez Prestige",
      description: "Black Finish",
      unit_price: 140000
    )

    search_params = {min_price: 130001}
    headers = {"CONTENT_TYPE" => "application/json"}

    get "/api/v1/items/find", headers: headers, params: search_params

    response_body = JSON.parse(response.body, symbolize_names: true)
    item = response_body[:data]

    expect(item).to be_a Hash

    expect(item[:attributes][:name]).not_to eq("Fender Stratocaster")
    expect(item[:attributes][:name]).to eq("Gibson Les Paul")
    expect(item[:attributes][:name]).not_to eq("Ibanez Prestige")
    expect(item[:attributes][:name]).not_to eq("Fender Telecaster")

    expect(item[:attributes][:description]).not_to eq("Seafoam Green Finish")
    expect(item[:attributes][:description]).to eq("Sunburst Finish")
    expect(item[:attributes][:description]).not_to eq("Black Finish")
    expect(item[:attributes][:description]).not_to eq("Butterscotch Blonde Finish")

    expect(item[:attributes][:unit_price]).not_to eq(100000)
    expect(item[:attributes][:unit_price]).to eq(200000)
    expect(item[:attributes][:unit_price]).not_to eq(120000)
    expect(item[:attributes][:unit_price]).not_to eq(130000)

    expect(item[:attributes][:merchant_id]).to eq(merchant_1.id)
  end

  it "can send one item based on maximum price search criteria, which returns the first item alphabetically by name" do
    merchant_1 = create(:merchant)

    merchant_1.items.create!(
      name: "Gibson Les Paul",
      description: "Sunburst Finish",
      unit_price: 200000
    )
    merchant_1.items.create!(
      name: "Fender Telecaster",
      description: "Butterscotch Blonde Finish",
      unit_price: 130000
    )
    merchant_1.items.create!(
      name: "Fender Stratocaster",
      description: "Seafoam Green Finish",
      unit_price: 100000
    )
    merchant_1.items.create!(
      name: "Ibanez Prestige",
      description: "Black Finish",
      unit_price: 120000
    )

    search_params = {max_price: 120001}
    headers = {"CONTENT_TYPE" => "application/json"}

    get "/api/v1/items/find", headers: headers, params: search_params

    response_body = JSON.parse(response.body, symbolize_names: true)
    item = response_body[:data]

    expect(item).to be_a Hash

    expect(item[:attributes][:name]).to eq("Fender Stratocaster")
    expect(item[:attributes][:name]).not_to eq("Gibson Les Paul")
    expect(item[:attributes][:name]).not_to eq("Ibanez Prestige")
    expect(item[:attributes][:name]).not_to eq("Fender Telecaster")

    expect(item[:attributes][:description]).to eq("Seafoam Green Finish")
    expect(item[:attributes][:description]).not_to eq("Sunburst Finish")
    expect(item[:attributes][:description]).not_to eq("Black Finish")
    expect(item[:attributes][:description]).not_to eq("Butterscotch Blonde Finish")

    expect(item[:attributes][:unit_price]).to eq(100000)
    expect(item[:attributes][:unit_price]).not_to eq(200000)
    expect(item[:attributes][:unit_price]).not_to eq(120000)
    expect(item[:attributes][:unit_price]).not_to eq(130000)

    expect(item[:attributes][:merchant_id]).to eq(merchant_1.id)
  end

  it "can send one item based on minimum and maximum price search criteria, which returns the first item alphabetically by name" do
    merchant_1 = create(:merchant)

    merchant_1.items.create!(
      name: "Gibson Les Paul",
      description: "Sunburst Finish",
      unit_price: 200000
    )
    merchant_1.items.create!(
      name: "Fender Telecaster",
      description: "Butterscotch Blonde Finish",
      unit_price: 130000
    )
    merchant_1.items.create!(
      name: "Fender Stratocaster",
      description: "Seafoam Green Finish",
      unit_price: 100000
    )
    merchant_1.items.create!(
      name: "Ibanez Prestige",
      description: "Black Finish",
      unit_price: 120000
    )

    search_params = {min_price: 100001, max_price: 150000}
    headers = {"CONTENT_TYPE" => "application/json"}

    get "/api/v1/items/find", headers: headers, params: search_params

    response_body = JSON.parse(response.body, symbolize_names: true)
    item = response_body[:data]

    expect(item).to be_a Hash

    expect(item[:attributes][:name]).not_to eq("Fender Stratocaster")
    expect(item[:attributes][:name]).not_to eq("Gibson Les Paul")
    expect(item[:attributes][:name]).not_to eq("Ibanez Prestige")
    expect(item[:attributes][:name]).to eq("Fender Telecaster")

    expect(item[:attributes][:description]).not_to eq("Seafoam Green Finish")
    expect(item[:attributes][:description]).not_to eq("Sunburst Finish")
    expect(item[:attributes][:description]).not_to eq("Black Finish")
    expect(item[:attributes][:description]).to eq("Butterscotch Blonde Finish")

    expect(item[:attributes][:unit_price]).not_to eq(100000)
    expect(item[:attributes][:unit_price]).not_to eq(200000)
    expect(item[:attributes][:unit_price]).not_to eq(120000)
    expect(item[:attributes][:unit_price]).to eq(130000)

    expect(item[:attributes][:merchant_id]).to eq(merchant_1.id)
  end

  it "users should get an error if name and either/both of the price parameters are sent" do
    merchant_1 = create(:merchant)

    merchant_1.items.create!(
      name: "Gibson Les Paul",
      description: "Sunburst Finish",
      unit_price: 200000
    )
    merchant_1.items.create!(
      name: "Fender Telecaster",
      description: "Butterscotch Blonde Finish",
      unit_price: 130000
    )
    merchant_1.items.create!(
      name: "Fender Stratocaster",
      description: "Seafoam Green Finish",
      unit_price: 100000
    )
    merchant_1.items.create!(
      name: "Ibanez Prestige",
      description: "Black Finish",
      unit_price: 120000
    )

    search_params = {name: "fender", max_price: 150000}
    headers = {"CONTENT_TYPE" => "application/json"}

    get "/api/v1/items/find", headers: headers, params: search_params

    expect(response).to have_http_status(500)
  end
end
