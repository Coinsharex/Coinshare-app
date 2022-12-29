# frozen_string_literal: true

require 'http'

module Coinbase
  # Get All donations that I made
  class GetMyDonations
    def initialize(config)
      @config = config
    end

    def call(current_account)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/donations/personal")

      response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
