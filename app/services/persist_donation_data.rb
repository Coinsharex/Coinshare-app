# frozen_string_literal: true

module Coinbase
  # Persist a new donation
  class PersistDonationData
    def initialize(config)
      @config = config
    end

    def call(current_account:, session:, request_id:, checkout_data:)
      data = {
        amount: checkout_data[:price].to_i,
        identifier: session['id'],
        comment: checkout_data[:comment],
        currency: session['currency'],
        anonymous: checkout_data[:anonymous] == 'true'
      }
      config_url = "#{@config.API_URL}/requests/#{request_id}/donations"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post(config_url, json: data)
    end
  end
end
