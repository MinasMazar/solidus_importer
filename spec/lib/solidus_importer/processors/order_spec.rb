# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusImporter::Processors::Order do
  describe '#call' do
    subject(:described_method) { described_class.call(context) }

    let(:context) { {} }

    context 'without order number in row data' do
      let(:context) do
        { data: 'Some data' }
      end

      it 'raises an exception' do
        expect { described_method }.to raise_error(SolidusImporter::Exception, 'Missing required key: "Name"')
      end
    end

    context 'with an order row with a file entity' do
      let(:context) do
        { data: data }
      end
      let(:data) { build(:solidus_importer_row_order, :with_import).data }

      before { allow(Spree::Store).to receive(:default).and_return(build_stubbed(:store)) }

      it 'returns an hash with :order' do
        described_method
        expect(context).to have_key(:order)
        expect(context[:order][:number]).to eq "R123456789"
      end

      it 'returns the order with some required keys with default values' do
        %i[
          number
          completed_at
          store
          currency
          email
          special_instructions
          line_items_attributes
          bill_address_attributes
          ship_address_attributes
          shipments_attributes
          payments_attributes
        ].each do |key|
          described_method
          expect(context[:order]).to have_key(key)
        end
      end
    end
  end
end
