# frozen_string_literal: true

module Coinbase
  # Behaviors of the donation_data
  class DonationData
    def initialize(stripe_session, request_id, checkout_data)
      @stripe_session = stripe_session
      @request_id = request_id
      @checkout_data = checkout_data
    end

    attr_reader :stripe_session, :request_id, :checkout_data

    def stripe_session_id
      @stripe_session['id']
    end

    def currency
      @stripe_session['currency']
    end

    def donation_comment
      @checkout_data['comment']
    end

    def anonymous?
      @checkout_data['anonymous'] == 'true'
    end

    def amount
      @checkout_data['price'].to_i
    end
  end
end
