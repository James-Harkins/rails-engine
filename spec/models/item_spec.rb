require "rails_helper"

describe Item, type: :model do
  describe "relationships" do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
  end

  describe "class methods" do
    describe "#find_by_name" do
      it "should return the first item in case-sensitive alphabetical order with a name including the search param" do
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

        expect(Item.find_by_name("fender")).to eq(item_3)
      end
    end

    describe "#find_by_min_and_max_price" do
      it "returns the first item alphabetically by name that is within the range of min and max prices passed in as arguments" do
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

        expect(Item.find_by_min_and_max_price(100001, 150000)).to eq(item_2)
      end
    end
  end
end
