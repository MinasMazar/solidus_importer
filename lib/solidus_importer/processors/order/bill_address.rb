# frozen_string_literal: true

module SolidusImporter
  module Processors
    module Order
      class BillAddress < Base
        def call(context)
          @data = context.fetch(:data)
          @order = context[:order]

          return if name.blank?

          check_data

          @order.bill_address = process_address
          @order.save!
        end

        private

        def check_data
          raise SolidusImporter::Exception, 'Order not found' if @order.blank?
        end

        def address
          @address ||= Spree::Address.find_or_initialize_by(
            address1: @data['Billing Address1'],
            address2: @data['Billing Address2'],
            city: @data['Billing City'],
            company: @data['Billing Company'],
            zipcode: @data['Billing Zip'],
            phone: @data['Billing Phone'],
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
          @data['Billing First Name']
        end

        def lastname
          @data['Billing Last Name']
        end

        def name
          "#{firstname} #{lastname}"
        end

        def process_address
          address.tap(&:save!)
        end

        def country_code
          @data['Billing Country Code']
        end

        def province_code
          @data['Billing Province Code']
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
