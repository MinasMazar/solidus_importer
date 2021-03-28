# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusImporter::Processors::Order::BillAddress do
  let(:described_instance) { described_class.new }

  describe '#call' do
    subject(:described_method) { described_instance.call(context) }

    before do
      create(:state, state_code: 'NM', country_iso: 'US')
    end

    let(:context) do
      { data: data, order: build(:order) }
    end
    let(:data) do
      {
        'Billing First Name' => 'John',
        'Billing Last Name' => 'Doe',
        'Billing Address1' => 'An address',
        'Billing Address2' => '',
        'Billing City' => 'My beautiful city',
        'Billing Company' => 'A Company',
        'Billing Zip' => '00000',
        'Billing Phone' => '555-123123123',
        'Billing Country Code' => 'US',
        'Billing Province Code' => 'NM'
      }
    end

    it "create order's bill address" do
      described_method
      expect(context).to have_key(:order)
      order = context[:order]
      expect(order).to be_an_instance_of(Spree::Order)
      expect(order.bill_address.city).to eq 'My beautiful city'
    end
  end
end
