# frozen_string_literal: true

module Coinbase
  # Returns list of requests based on category
  class GetRequestsByCategory
    def initialize(config)
      @config = config
    end

    def call(current_account:, category:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/requests/categories/#{category}")

      response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
    end
  end
end
