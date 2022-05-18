require "rails_helper"

describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many :items }
  end

  describe "class methods" do
    describe "#find_all_by_name" do
      it "should return, case-insensitive, all merchants whose name partially matches the search param, in alphabetical order" do
        merchant_1 = Merchant.create(name: "Leo Fender")
        merchant_2 = Merchant.create(name: "Doug West")
        merchant_3 = Merchant.create(name: "Brian Fender")
        merchant_4 = Merchant.create(name: "Orville Gibson")
        merchant_5 = Merchant.create(name: "Bill Fender")

        expect(Merchant.find_all_by_name).to eq([merchant_5, merchant_3, merchant_1])
        expect(Merchant.find_all_by_name.include?(merchant_2)).to eq false
        expect(Merchant.find_all_by_name.include?(merchant_4)).to eq false
      end
    end
  end
end
