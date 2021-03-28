# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusImporter::Processors::Order::LineItem do
  describe '#call' do
    subject(:described_method) { described_class.call(context) }

    context 'without a target order' do
      let(:context) do
        { data: { 'Lineitem sku' => 'a-valid-sku' }, order: nil }
      end
      let!(:variant) { create(:variant, sku: 'a-valid-sku', price: 10.0) }

      it 'creates the meta-model for Spree::LineItem' do
        expect { described_method }.to raise_error(SolidusImporter::Exception, 'no :order given')
      end
    end

    context 'with an order and a "Lineitem sky/quantity/price"' do
      let(:context) do
        { data: data, order: order }
      end
      let(:order) { create(:completed_order_with_totals, line_items_count: 0) }
      let(:data) do
        {
          'Lineitem sku' => 'a-valid-sku',
          'Lineitem quantity' => '2',
          'Lineitem price' => '11.40',
        }
      end
      let!(:variant) { create(:variant, sku: 'a-valid-sku', price: 10.0) }
      let(:line_item) { Spree::LineItem.first }

      it 'creates the meta-model for Spree::LineItem' do
        expect { described_method }.to change(Spree::LineItem, :count).from(0)
      end

      it 'creates line item with correct attributes' do
        described_method
        expect(line_item.order).to eq order
        expect(line_item.variant).to eq variant
        expect(line_item.sku).to eq 'a-valid-sku'
        expect(line_item.quantity).to eq 2
        expect(line_item.price).to eq 11.40
      end

      context 'when the variant does not exist' do
        let!(:variant) {}

        it 'raise an exception' do
          expect { described_method }.to raise_error(SolidusImporter::Exception, "No valid variant found with sku a-valid-sku")
        end
      end
    end
  end
end
