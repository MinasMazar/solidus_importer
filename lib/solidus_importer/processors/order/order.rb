# frozen_string_literal: true

module SolidusImporter
  module Processors
    module Order
      class Order < Base
        def call(context)
          @data = context.fetch(:data)
          check_data

          order = prepare_order
          order.save!

          context.merge!(order: order)
        end

        def options
          @options ||= {
            store: Spree::Store.default
          }
        end

        def prepare_order
          order = Spree::Order.find_or_initialize_by(number: number)
          order.currency = currency
          order.completed_at = completed_at
          order.email = email
          order.user = user
          order.special_instructions = special_instructions
          order
        end

        private

        def check_data
          raise SolidusImporter::Exception, 'Missing required key: "Name"' if @data['Name'].blank?
        end

        def completed_at
          processed_at = @data['Processed At']
          processed_at ? Time.parse(processed_at).in_time_zone : Time.current
        rescue ArgumentError
          Time.current
        end

        def currency
          @data['Currency']
        end

        def email
          @data['Email']
        end

        def number
          @data['Name']
        end

        def special_instructions
          @data['Note']
        end

        def user
          @user ||= Spree::User.find_by(email: email)
        end
      end
    end
  end
end
