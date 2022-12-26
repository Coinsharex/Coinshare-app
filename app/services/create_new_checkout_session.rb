# frozen_string_literal: true

require 'stripe'

module Coinbase
  # Create a new checkout session
  class CreateNewCheckoutSession
    def initialize(config)
      @config = config
    end

    def call(current_account:, checkout_data:)
      #   config_url = "#{api_url}/checkout"
      #   response = HTTP.auth("Bearer #{current_account.auth_token}")
      #                  .post(config_url, json: checkout_data)
      #   JSON.parse(response.body.to_s)
      Stripe.api_key = @config.STRIPE_API_KEY

      price = (checkout_data[:price].to_i * 100 * 1.08).to_i

      Stripe::Checkout::Session.create({
                                         customer_email: current_account.email,
                                         submit_type: 'donate',
                                         line_items: [{
                                           # Provide the exact Price ID (e.g. pr_1234) of the product you want to sell
                                           price_data: { currency: 'usd',
                                                         product_data: { name: 'Donation' },
                                                         unit_amount: price },
                                           quantity: 1
                                         }],
                                         mode: 'payment',
                                         success_url: "#{@config.APP_URL}/success",
                                         cancel_url: "#{@config.APP_URL}/cancel"
                                       })
    end
  end
end
