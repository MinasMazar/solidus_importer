# frozen_string_literal: true

require_relative 'address'

module SolidusImporter
  module Processors
    class ShipAddress < Address
      def call(context)
        @data = context[:data]

        return if name.empty?

        order = context.fetch(:order, {})

        order[:ship_address_attributes] = ship_address_attributes

        context.merge!(order: order)
      end

      def country_code
        @data['Shipping Country Code'] || @data['Shipping Country']
      end

      def province_code
        @data['Shipping Province Code'] || @data['Shipping Province']
      end

      def name
        @data['Shipping Name'] || "#{firstname} #{lastname}"
      end

      def firstname
        @data['Shipping First Name']
      end

      def lastname
        @data['Shipping Last Name']
      end

      private

      def ship_address_attributes
        {
          name: name,
          address1: @data['Shipping Address1'],
          address2: @data['Shipping Address2'],
          city: @data['Shipping City'],
          company: @data['Shipping Company'],
          zipcode: @data['Shipping Zip'],
          phone: @data['Shipping Phone'],
          country: extract_country(country_code),
          state: extract_state(province_code)
        }
      end
    end
  end
end
