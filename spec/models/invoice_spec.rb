require "rails_helper"

describe Invoice, type: :model do
  describe "relationships" do
    it { should have_many :invoice_items }
    it { should have_many(:items).through(:invoice_items) }
  end

  describe "class methods" do
    describe "#only_containing_item" do
      it "should return all invoices only containing the item whose id is passed in as an argument" do
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

        expect(Invoice.only_containing_item(item_4.id)).to eq([invoice_2, invoice_5])
      end
    end
  end
end
