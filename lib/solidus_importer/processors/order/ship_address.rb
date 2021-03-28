# frozen_string_literal: true

module SolidusImporter
  module Processors
    module Order
      class ShipAddress < Base
        def call(context)
          @data = context.fetch(:data)
          @order = context[:order]

          return if name.blank?

          check_data

          @order.ship_address = process_address
          @order.save!
        end

        private

        def check_data
          raise SolidusImporter::Exception, 'Order not found' if @order.blank?
        end

        def address
          @address ||= Spree::Address.find_or_initialize_by(
            address1: @data['Shipping Address1'],
            address2: @data['Shipping Address2'],
            city: @data['Shipping City'],
            company: @data['Shipping Company'],
            zipcode: @data['Shipping Zip'],
            phone: @data['Shipping Phone'],
            country: country,
            state: state
          )

          if SolidusImporter.combined_first_and_last_name_in_address?
            @address.name = name
          else
            @address.firstname = firstname
            @address.lastname = lastname
          end

          @address
        end

        def firstname
          @data['Shipping First Name']
        end

        def lastname
          @data['Shipping Last Name']
        end

        def name
          "#{firstname} #{lastname}"
        end

        def process_address
          address.tap(&:save!)
        end

        def country_code
          @data['Shipping Country Code']
        end

        def province_code
          @data['Shipping Province Code']
        end

        def country
          @country ||= Spree::Country.find_by(iso: country_code) if country_code
        end

        def state
          @state ||= country&.states&.find_by(abbr: province_code) if province_code
        end
      end
    end
  end
end
