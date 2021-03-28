# frozen_string_literal: true

module SolidusImporter
  module Processors
    module Order
      class Payment < Base
        attr_accessor :order

        def call(context)
          @data = context.fetch(:data)

          self.order = context.fetch(:order)

          check_data

          return if transaction_amount.zero?

          context.merge!(payment: process_payment)
        end

        def default_payment_method
          @default_payment_method ||= Spree::PaymentMethod.find_or_initialize_by(
            name: 'SolidusImporter PaymentMethod',
            type: 'Spree::PaymentMethod::Check'
          ).tap(&:save)
        end

        private

        def check_data
          handle_missing_order if order.blank?
        end

        def transaction_amount
          @data['Transaction Amount'].to_d
        end

        def transaction_status
          status = @data['Transaction Status']
          return 'success' if status.blank?

          status
        end

        def evaluate_state
          transaction_status.inquiry.success? && 'completed'
        end

        def payment
          @payment ||= prepare_payment
        end

        def prepare_payment
          Spree::Payment.new do |new_payment|
            new_payment.state = evaluate_state
            new_payment.order_id = order.id
            new_payment.amount = transaction_amount
            new_payment.payment_method = default_payment_method
            new_payment.source = default_payment_method
          end
        end

        def process_payment
          payment.tap(&:save!)
        end

        def handle_missing_order
          raise(SolidusImporter::Exception, 'no :order given')
        end
      end
    end
  end
end
