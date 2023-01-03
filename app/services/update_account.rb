# frozen_string_literal: true

require 'http'

module Coinbase
  # Service Object to allow users to update their account
  class UpdateAccount
    class ApiServerError < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, data:)
      unless data[:picture].nil?
        photo = Object::File.read(data[:picture][:tempfile])
        photo_encoded = Base64.strict_encode64(photo)
        data[:picture] = photo_encoded
      end
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .put("#{api_url}/accounts/#{current_account.email}", json: data)
      raise ApiServerError unless response.code == 200

      JSON.parse(response.body.to_s)['data']
    end
  end
end
