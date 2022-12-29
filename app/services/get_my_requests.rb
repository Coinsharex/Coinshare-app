# frozen_string_literal: true

require 'http'

module Coinbase
  # Get requests made by the user
  class GetMyRequests
    def initialize(config)
      @config = config
    end

    def call(current_account)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/requests/personal")

      response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
