# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusImporter::Processors::ShipAddress do
  describe '#call' do
    subject(:described_method) { described_class.call(context) }

    let(:context) do
      { data: data }
    end
    let(:data) do
      {
        'Shiping First Name' => 'John',
        'Shiping Last Name' => 'Doe',
        'Shiping Address1' => 'An address',
        'Shiping Address2' => '',
        'Shiping City' => 'A Beautyful city',
        'Shiping Company' => 'A Company',
        'Shiping Zip' => '00000',
        'Shiping Phone' => '555-123123123',
        'Shiping Country Code' => 'US',
        'Shiping Province Code' => 'NM'
      }
    end

    it 'put ship_address_attributes into order data' do
      described_method
      expect(context).to have_key(:order)
      expect(context[:order][:ship_address_attributes]).not_to be_empty
    end
  end
end
