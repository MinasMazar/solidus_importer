# frozen_string_literal: true

module SolidusImporter
  class Configuration < Spree::Preferences::Configuration
    preference :solidus_importer, :hash, default: {
      customers: {
        importer: SolidusImporter::BaseImporter,
        processors: [
          SolidusImporter::Processors::Customer::Customer,
          SolidusImporter::Processors::Customer::CustomerAddress,
          SolidusImporter::Processors::Log
        ]
      },
      orders: {
        importer: SolidusImporter::SpreeCoreOrderImporter::OrderImporter,
        processors: [
          SolidusImporter::Processors::SpreeCoreOrderImporter::Order,
          SolidusImporter::Processors::SpreeCoreOrderImporter::BillAddress,
          SolidusImporter::Processors::SpreeCoreOrderImporter::ShipAddress,
          SolidusImporter::Processors::SpreeCoreOrderImporter::LineItem,
          SolidusImporter::Processors::SpreeCoreOrderImporter::Shipment,
          SolidusImporter::Processors::SpreeCoreOrderImporter::Payment,
          SolidusImporter::Processors::Log
        ]
      },
      orders_v2: {
        importer: SolidusImporter::BaseImporter,
        processors: [
          SolidusImporter::Processors::Order::Order,
          SolidusImporter::Processors::Order::BillAddress,
          SolidusImporter::Processors::Order::ShipAddress,
          SolidusImporter::Processors::Order::LineItem,
          SolidusImporter::Processors::Order::Payment,
          SolidusImporter::Processors::Log
        ]
      },
      products: {
        importer: SolidusImporter::BaseImporter,
        processors: [
          SolidusImporter::Processors::Product::Product,
          SolidusImporter::Processors::Product::Variant,
          SolidusImporter::Processors::Product::OptionTypes,
          SolidusImporter::Processors::Product::OptionValues,
          SolidusImporter::Processors::Product::ProductImages,
          SolidusImporter::Processors::Product::VariantImages,
          SolidusImporter::Processors::Log
        ]
      }
    }

    def available_types
      solidus_importer.keys
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
