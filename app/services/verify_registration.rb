# frozen_string_literal: true

require 'http'

module Coinbase
  # Returns an authenticated user, or nil
  class VerifyRegistration
    class VerificationError < StandardError; end
    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(registration_data)
      regis_data = registration_data.to_h
      registration_token = SecureMessage.encrypt(regis_data)
      regis_data[:verification_url] =
        "#{@config.APP_URL}/auth/register/#{registration_token}"

      response = HTTP.post("#{@config.API_URL}/auth/register",
                           json: regis_data)

      raise(VerificationError) unless response.code == 202

      JSON.parse(response.to_s)
    rescue HTTP::ConnectionError
      raise(ApiServerError)
    end
  end
end
