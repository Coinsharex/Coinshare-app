# frozen_string_literal: true

require 'http'

module Coinbase
  # Service Object to transfer the funds to the Bank API
  class TransferFunds
    def initialize(config)
      @config = config
    end

    def call(data:)
      donation_data = {
        amount: data.amount,
        identifier: data.stripe_session_id,
        comment: data.donation_comment,
        currency: data.currency,
        anonymous: data.anonymous?
      }
      config_url = "#{@config.API_URL}/requests/#{data.request_id}/donations"
      HTTP.auth("Bearer #{current_account.auth_token}")
          .post(config_url, json: donation_data)
    end
  end
end
