# frozen_string_literal: true

module SolidusImporter
  module Processors
    module Order
      class Payment < Base
        attr_accessor :order

        def call(context)
          @data = context.fetch(:data)
          self.order = context.fetch(:order)

          return if order.blank? || !transaction_status.success?

          @payment = order.payments.first || prepare_payment
          @payment.amount = amount
          @payment.save!
        end

        def default_payment_method
          @default_payment_method ||= Spree::PaymentMethod.find_or_initialize_by(
            name: 'SolidusImporter PaymentMethod',
            type: 'Spree::PaymentMethod::Check'
          ).tap(&:save)
        end

        private

        def amount
          order.line_items.sum(&:total)
        end

        def transaction_status
          (@data['Transaction Status'] || 'success').inquiry
        end

        def prepare_payment
          Spree::Payment.new do |new_payment|
            new_payment.state = :completed
            new_payment.order_id = order.id
            new_payment.amount = amount
            new_payment.payment_method = default_payment_method
            new_payment.source = default_payment_method
          end
        end
      end
    end
  end
end
