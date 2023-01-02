# frozen_string_literal: true

require 'http'

module Coinbase
  # Service Object to allow users to delete request
  class DeleteRequest
    class NotAllowedError < StandardError; end
    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, request_id:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .delete("#{api_url}/requests/#{request_id}")

      raise NotAllowedError if response.code == 403
      raise(ApiServerError) if response.code != 200
    end
  end
end
