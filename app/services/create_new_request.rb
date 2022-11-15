# frozen_string_literal: true

require 'http'

module Coinbase
  # Create a new configuration file for a request
  class CreateNewRequest
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, request_data:)
      config_url = "#{api_url}/requests"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post(config_url, json: request_data)

      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
