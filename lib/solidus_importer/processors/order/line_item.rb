# frozen_string_literal: true

module SolidusImporter
  module Processors
    module Order
      class LineItem < Base
        attr_accessor :order

        def call(context)
          @data = context.fetch(:data)

          self.order = context.fetch(:order)

          return if variant_sku.blank?

          check_data

          order.line_items << process_line_item
        end

        private

        def check_data
          handle_missing_order if order.blank?
          handle_missing_variant if variant.blank?
        end

        def line_item
          @line_item ||= Spree::LineItem.new do |line_item|
            line_item.order_id = order.id
            line_item.variant_id = variant.id
            line_item.quantity = quantity
            line_item.price = price
          end
        end

        def process_line_item
          line_item.tap(&:save!)
        end

        def price
          @data['Lineitem price']
        end

        def quantity
          @data['Lineitem quantity']
        end

        def variant
          @variant ||= Spree::Variant.find_by(sku: variant_sku)
        end

        def variant_sku
          @data['Lineitem sku']
        end

        def handle_missing_order
          raise(SolidusImporter::Exception, 'no :order given')
        end

        def handle_missing_variant
          raise(SolidusImporter::Exception, "No valid variant found with sku #{variant_sku}")
        end
      end
    end
  end
end
