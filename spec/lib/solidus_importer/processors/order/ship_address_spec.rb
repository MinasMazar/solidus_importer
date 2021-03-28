# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusImporter::Processors::Order::ShipAddress do
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
        'Shipping First Name' => 'John',
        'Shipping Last Name' => 'Doe',
        'Shipping Address1' => 'An address',
        'Shipping Address2' => '',
        'Shipping City' => 'My beautiful city',
        'Shipping Company' => 'A Company',
        'Shipping Zip' => '00000',
        'Shipping Phone' => '555-123123123',
        'Shipping Country Code' => 'US',
        'Shipping Province Code' => 'NM'
      }
    end

    it 'put ship_address_attributes into order data' do
      described_method
      expect(context).to have_key(:order)
      order = context[:order]
      expect(order).to be_an_instance_of(Spree::Order)
      expect(order.ship_address.city).to eq 'My beautiful city'
    end
  end
end
