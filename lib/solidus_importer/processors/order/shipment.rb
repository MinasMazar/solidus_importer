# frozen_string_literal: true

module SolidusImporter
  module Processors
    module Order
      class Shipment < Base
        STATES_MAPPING = {
          'fulfilled' => 'ready'
        }.freeze

        attr_accessor :line_item, :order, :stock_location

        def call(context)
          @data = context.fetch(:data)

          self.order = context.fetch(:order)
          self.stock_location = context.fetch(:stock_location, default_stock_location)

          check_data

          self.line_item = context[:line_item]

          return if line_item.blank?
          return if evaluate_state.inquiry.pending?

          order.shipments << process_shipment
        end

        def options
          @options ||= {
            default_stock_location_name: 'SolidusImporter [previous locaiton]'
          }
        end

        def default_calculator
          @default_calculator ||= Spree::Calculator.find_or_initialize_by(
            calculable_type: 'Spree::ShippingMethod',
            &:save!
          )
        end

        def default_shipping_category
          @default_shipping_category ||= Spree::ShippingCategory.find_or_initialize_by(
            name: '[solidus_importer]'
          ) do |shipping_category|
          end
        end

        def default_shipping_method
          @default_shipping_method ||= Spree::ShippingMethod.find_or_initialize_by(
            name: '[solidus_importer]'
          ) do |shipping_method|
            shipping_method.calculator = default_calculator
            shipping_method.shipping_categories << default_shipping_category
            shipping_method.save!
          end
        end

        def default_stock_location
          @default_stock_location ||= Spree::StockLocation.find_or_initialize_by(
            name: '[solidus_importer]'
          ) do |stock_location|
            stock_location.save!
          end
        end

        private

        def check_data
          handle_missing_order if order.blank?
        end

        def evaluate_state
          STATES_MAPPING[fulfillment_status] || 'pending'
        end

        def fulfillment_status
          @data['Lineitem fulfillment status']
        end

        def shipment
          @shipment ||= Spree::Shipment.new do |shipment|
            shipment.order_id = order.id
            shipment.state = evaluate_state
            shipment.cost = 0.0
            shipment.stock_location_id = stock_location.id
          end
        end

        def process_shipment
          shipment.save!

          shipment.shipping_rates.create(
            shipping_method: default_shipping_method,
            selected: true,
            cost: shipment.cost
          )

          inventory_unit = Spree::InventoryUnit.new(
            shipment: shipment,
            line_item: line_item,
            variant: line_item.variant
          )

          inventory_unit.save!

          shipment
        end

        def handle_missing_order
          raise(SolidusImporter::Exception, 'no :order given')
        end
      end
    end
  end
end
