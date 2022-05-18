require "rails_helper"

describe Item, type: :model do
  describe "relationships" do
    it { should belong_to :merchant }
  end

  describe "class methods" do
    describe "#find_by_name" do
      it "should return the first item in case-sensitive alphabetical order with a name including the searhch param" do
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
  end
end
