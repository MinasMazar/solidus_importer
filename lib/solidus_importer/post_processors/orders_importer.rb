# frozen_string_literal: true

module SolidusImporter
  module PostProcessors
    class OrdersImporter < SolidusImporter::Processors::Base
      class CustomAdjuster
        def initialize(_order)
        end

        def adjust!
        end
      end

      def call(ending_context)
        (ending_context[:imported_orders] || []).each do | params|
          begin
            adjuster = Spree::Config.tax_adjuster_class
            Spree::Config.tax_adjuster_class = CustomAdjuster

            Spree::Core::Importer::Order.import(nil, params)

            Spree::Config.tax_adjuster_class = adjuster
          rescue StandardError => err
            ending_context.merge!(message: err.message)
          end
        end
      end
    end
  end
end
