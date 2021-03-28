# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusImporter::Processors::Order::Shipment do
  describe '#call' do
    subject(:described_method) { described_class.call(context) }

    let(:context) do
      {
        data: data,
        line_item: line_item,
        stock_location: stock_location,
        order: order
      }
    end
    let(:data) {}
    let(:stock_location) { create(:stock_location) }
    let(:line_item) { order&.line_items&.first }
    let!(:order) { create(:order_with_line_items) }

    context 'without a target order' do
      let(:order) {}

      it 'creates the meta-model for Spree::Shipment' do
        expect { described_method }.to raise_error(SolidusImporter::Exception, 'no :order given')
      end
    end

    context 'when "Lineitem fulfilled status" is "fulfilled"' do
      let(:data) do
        {
          'Lineitem fulfillment status' => 'fulfilled'
        }
      end
      let(:shipment) { Spree::Shipment.last }

      it 'creates a Spree::Shipment for the order' do
        expect { described_method }.to change(Spree::Shipment, :count).by(1)
        expect(shipment.order).to eq order
        expect(shipment.state).to eq 'ready'
        expect(shipment.stock_location).to eq stock_location
        expect(shipment.shipping_method).not_to be_blank
      end

      context 'when "Lineitem fulfilled status" is not "fulfilled"' do
        let(:data) do
          {
            'Lineitem fulfillment status' => nil
          }
        end

        it 'creates a Spree::Shipment for the order' do
          expect { described_method }.not_to change(Spree::Shipment, :count)
        end
      end
    end
  end
end
