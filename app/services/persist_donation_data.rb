# frozen_string_literal: true

module Coinbase
  # Persist a new donation
  class PersistDonationData
    def initialize(config)
      @config = config
    end

    def call(current_account:, data:)
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
