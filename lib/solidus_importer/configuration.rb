# frozen_string_literal: true

module SolidusImporter
  class Configuration < Spree::Preferences::Configuration
    preference :solidus_importer, :hash, default: {
      customers: {
        importer: SolidusImporter::BaseImporter,
        processors: [
          SolidusImporter::Processors::Customer,
          SolidusImporter::Processors::CustomerAddress,
          SolidusImporter::Processors::Log
        ]
      },
      orders: {
        importer: SolidusImporter::OrderImporter,
        processors: [
          SolidusImporter::Processors::Order,
          SolidusImporter::Processors::BillAddress,
          SolidusImporter::Processors::ShipAddress,
          SolidusImporter::Processors::LineItem,
          SolidusImporter::Processors::Shipment,
          SolidusImporter::Processors::Payment,
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
