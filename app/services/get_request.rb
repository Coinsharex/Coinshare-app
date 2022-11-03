# frozen_string_literal: true

module Coinbase
  # Returns details about a single request
  class GetRequest
    def initialize(config)
      @config = config
    end

    def call(current_account:, request_id:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/requests/#{request_id}")

      response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
    end
  end
end
