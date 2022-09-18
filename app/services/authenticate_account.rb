# frozen_string_literal: true

require 'http'

module Coinbase
  # Returns an authenticated user, or nil
  class AuthenticateAccount
    class UnauthorizedError < StandardError; end

    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(email:, password:)
      response = HTTP.post("#{@config.API_URL}/auth/authenticate",
                           json: { email:, password: })

      raise(UnauthorizedError) if response.code == 403
      raise(ApiServerError) if response.code != 200

      response.parse['attributes']
    end
  end
end
